#ifndef SSAO_CGINC
#define SSAO_CGINC

#include "UnityCG.cginc"

sampler2D _CameraDepthTexture;    
sampler2D _CameraDepthNormalsTexture;    

float RandomFloat(float2 uv) // [0,1]
{
    float2 noise = (frac(sin(dot(uv, float2(12.9898, 78.233) * 2.0)) * 43758.5453)); // frac返回小数部分
    return abs(noise.x + noise.y) * 0.5;
}

float3 RandomVec(float2 uv){ // 法线空间随机向量
    float3 vec = float3(0,0,0);
    vec.x = RandomFloat(uv) * 2.0 - 1.0;
    vec.y = RandomFloat(uv * uv) * 2.0 - 1.0;
    vec.z = RandomFloat(uv * uv * uv);
    vec = normalize(vec);
    return vec;
}

float3 NoiseInXY(float2 uv){
    float3 vec = float3(0,0,0);
    vec.x = RandomFloat(uv) * 2.0 - 1.0;
    vec.y = RandomFloat(uv) * 2.0 - 1.0;
    vec.z = 0.0;
    return vec;
}

float3 GetViewPos(float2 uv){
    float depth = tex2D(_CameraDepthTexture,uv).r; // 这里的深度是非线性[0,1]
    #if UNITY_REVERSED_Z
        depth = 1.0 - depth;
    #endif

    float4 ndc = float4(uv,depth,1.0);
    ndc.xyz = ndc.xyz * 2.0 - 1.0;
    float4 viewPos = mul(unity_CameraInvProjection,ndc);
    viewPos /= viewPos.w;

    return viewPos.xyz;
}

float3 GetViewNormal(float2 uv){
    float depth;
    float3 viewNormal;
    float4 depthNormal = tex2D(_CameraDepthNormalsTexture,uv);
    DecodeDepthNormal(depthNormal,depth,viewNormal); // 这里解码出来的深度是线性的[0,1]，法线是视图空间的
    viewNormal = normalize(viewNormal);

    return viewNormal;
}

float GetViewLinearDepth(float2 uv)
{
    float _sampleDepth = tex2D(_CameraDepthTexture,uv).r;
    #if UNITY_REVERSED_Z
    _sampleDepth = 1.0 - _sampleDepth;
    #endif

    float z = _sampleDepth * 2.0 - 1.0; 
    return (2.0 * _ProjectionParams.y * _ProjectionParams.z) / (_ProjectionParams.z + _ProjectionParams.y - z * (_ProjectionParams.z - _ProjectionParams.y));	
}

#endif
