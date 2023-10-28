#ifndef CLOUD_CGINC
#define CLOUD_CGINC

#include "UnityCG.cginc"
#include "Lighting.cginc"

#define kPI 3.1415926
#define SUN_DIR normalize(_WorldSpaceLightPos0.xyz)

sampler2D _MainTex;
uniform sampler3D _cloudShape;
uniform sampler3D _cloudDetail;
uniform sampler2D _cloudCoverage;

uniform float3 box_min;
uniform float3 box_max;
uniform float4x4 pro_i;
uniform float4x4 vie_i;

uniform float _cloudType;
uniform float _cloudFactor;
uniform float _lightIntensity;

float3 mix(float3 x,float3 y,float a)
{
    return x * (1.0 - a) + y * a;
}

float mix(float x,float y,float a)
{
    return x * (1.0 - a) + y * a;
}

float3 getDir(float2 uv)
{
    float4 ndc = float4(uv * 2.0 - 1.0,1.0,1.0);

    float4 view_pos = mul(pro_i,ndc);
    view_pos.xyz /= view_pos.w;
    view_pos.w = 0.0; // w 等于0 代表向量

    float4 world_pos = mul(vie_i,view_pos);

    return normalize(world_pos.xyz);
}

float2 getUV(float3 pos)
{
    return (pos.xz / box_max.xz) * 0.5 + 0.5;
}

float getHeightPercent(float3 pos)
{
    return (pos.y - box_min.y) / (box_max.y - box_min.y);
}

float remap(float originalValue, float originalMin, float originalMax, float newMin, float newMax)
{
	return newMin + (((originalValue - originalMin) / (originalMax - originalMin)) * (newMax - newMin));
}

float3 getSkyColor(float3 dir){
    float t = (dir.y + 1.0) * 0.5;
    return (1.0 - t) * float3(1.0, 1.0, 1.0) + t * float3(0.5, 0.7, 1.0);
}

bool hitbox(float3 ro,float3 rd,inout float3 start,inout float3 end)
{
    float3 tmin = (box_min - ro) / rd;
    float3 tmax = (box_max - ro) / rd;

    float3 t1 = min(tmin,tmax);
    float3 t2 = max(tmin,tmax);

    float entt = max(t1.x,max(t1.y,t1.z));
    float outt = min(t2.x,min(t2.y,t2.z));

    if(entt > outt || outt < 0) return false;

    entt = max(0,entt);

    start = ro + entt * rd;
    end   = ro + outt * rd;

    return true;
}

float hgPhase(float g, float cosTheta)
{
    float numer = 1.0f - g * g;
    float denom = 1.0f + g * g + 2.0f * g * cosTheta;
    return numer / (4.0f * kPI * denom * sqrt(denom));
}

float dualLobPhase(float g0, float g1, float w, float cosTheta)
{
    return mix(hgPhase(g0, cosTheta), hgPhase(g1, cosTheta), w);
}

#define STRATUS_GRADIENT float4(0.0, 0.1, 0.2, 0.3)
#define STRATOCUMULUS_GRADIENT float4(0.02, 0.2, 0.48, 0.625)
#define CUMULUS_GRADIENT float4(0.00, 0.1625, 0.88, 0.98)
float getDensityForCloud(float heightFraction, float cloudType)
{
	float stratusFactor = 1.0 - clamp(cloudType * 2.0, 0.0, 1.0);
	float stratoCumulusFactor = 1.0 - abs(cloudType - 0.5) * 2.0;
	float cumulusFactor = clamp(cloudType - 0.5, 0.0, 1.0) * 2.0;

	float4 baseGradient = stratusFactor * STRATUS_GRADIENT + stratoCumulusFactor * STRATOCUMULUS_GRADIENT + cumulusFactor * CUMULUS_GRADIENT;
	return smoothstep(baseGradient.x, baseGradient.y, heightFraction) - smoothstep(baseGradient.z, baseGradient.w, heightFraction);
}

float getDensity(float3 pos)
{
    float height = getHeightPercent(pos);
    if(height < 0.0 || height > 1.0){
		return 0.0;
	}
    float2 uv = getUV(pos);
    float2 move_uv = getUV(pos
    + height * normalize(float3(0.5, 0.1,0)) * 2.
    + normalize(float3(0.5, 0.1,0)) * _Time.y);

    float4 low_frequency = tex3Dlod(_cloudShape,float4(uv,height,0));
    float fbm = dot(low_frequency.gba,float3(0.625,0.25,0.125));
    float base_cloud = remap(low_frequency.r, -(1.0 - fbm), 1., 0.0 , 1.0);

    float density = getDensityForCloud(height, _cloudType);
	base_cloud = (density / height) * 0.6;

    float3 weather_data = tex2D(_cloudCoverage, uv).rgb;
	float cloud_coverage = weather_data.r * 0.6;
	float base_cloud_with_coverage = remap(base_cloud , cloud_coverage , 1.0 , 0.0 , 1.0);
	base_cloud_with_coverage *= cloud_coverage;

    float3 erodeCloudNoise = tex3Dlod(_cloudDetail, float4(move_uv, height,0)).rgb;
	float highFreqFBM = dot(erodeCloudNoise.rgb, float3(0.625, 0.25, 0.125));
	float highFreqNoiseModifier = mix(highFreqFBM, 1.0 - highFreqFBM, clamp(height * 10.0, 0.0, 1.0));
	base_cloud_with_coverage = base_cloud_with_coverage - highFreqNoiseModifier * (1.0 - base_cloud_with_coverage);
	base_cloud_with_coverage = remap(base_cloud_with_coverage*2.0, highFreqNoiseModifier * 0.2, 1.0, 0.0, 1.0);
                
    return base_cloud_with_coverage;
}


float raymarchtolight(float3 start,float ds)
{
    float3 dir = normalize(_WorldSpaceLightPos0.xyz);
    float3 matchdir = dir * ds;

    float3 pos = start;
    float T = 1.0;
    for(int i=0;i<6;i++)
    {
        float density = getDensity(pos);
        if(density > 0)
        {
            T *= exp(-density * ds);
        }
        pos += matchdir;
    }

    return T;
}

float4 raymarch(float3 start,float3 end,float3 bg)
{
    float3 path = end - start;
    float len = length(path);
    float ds = len / 32.0f;
    float3 matchDir = normalize(path) * ds;

    float T = 1.0;
    float3 scattering = float3(0,0,0);
    float3 VoL =  dot(normalize(path),normalize(_WorldSpaceLightPos0.xyz));
    float3 pos = start + normalize(path) * 0.01;

    [unroll(32)]
    for(int i=0;i<32;i++)
    {
        float _density = getDensity(pos);
        if(_density > 0.)
        {
            float dTrans = exp(-_density * ds * _cloudFactor);

            float light_ds = raymarchtolight(pos,ds * 0.1);
            float sunPhase = dualLobPhase(0.5, -0.5, 0.2, -VoL);
            float3 stepScattering = float3(1,1.,0.9) * dTrans * sunPhase * light_ds * _lightIntensity;
            float3 sigmaS = float3(_density,_density,_density);
            scattering += stepScattering * T * (sigmaS * ds);

            T *= dTrans;
        }
        if(T < 1e-1) break;
        pos += matchDir;

    }
    float3 finalColor = T * bg + scattering;

    return float4(finalColor,T);
}

#endif