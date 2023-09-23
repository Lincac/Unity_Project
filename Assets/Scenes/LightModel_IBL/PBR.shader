Shader "PBR"
{
    Properties
    {
        _Albedo ("Albedo", 2D) = "white" {}
        _Normal ("Normal", 2D) = "bump" {}
        _Roughness ("Roughness", 2D) = "white" {}
        _Metallic ("Metallic", 2D) = "white" {}
        _Ao ("Ao", 2D) = "white" {}

        _Irradiance ("Irradiance",CUBE) = "white" {}
        _Prefilter ("Prefilter",CUBE) = "white" {}
        _LUT ("LUT",2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "LightMode"="ForwardAdd" } // 必须要声明光照模式才能使用光源的相关信息
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "PBR.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
                float3 normalWS : TEXCOORD2;
                float3 tangentWS : TEXCOORD3;
                float3 bitangentWS : TEXCOORD4;
            };

            sampler2D _Albedo;
            sampler2D _Normal;
            sampler2D _Roughness;
            sampler2D _Metallic;
            sampler2D _Ao;
            samplerCUBE _Irradiance;
            samplerCUBE _Prefilter;
            sampler2D _LUT;

		    float3 ACESToneMapping(float3 x)
		    {
			    float a = 2.51f;
			    float b = 0.03f;
			    float c = 2.43f;
			    float d = 0.59f;
			    float e = 0.14f;
			    return saturate((x*(a*x + b)) / (x*(c*x + d) + e));
		    }

            v2f vert (appdata_tan v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                o.positionWS = mul(unity_ObjectToWorld,v.vertex).xyz;
                o.normalWS = normalize(mul(float4(v.normal,0.0),unity_WorldToObject).xyz);
                o.tangentWS = normalize(mul(unity_ObjectToWorld,float4(v.tangent.xyz,0.0)).xyz);
                o.bitangentWS = normalize(cross(o.normalWS,o.tangentWS) * v.tangent.w) ;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 T = normalize(i.tangentWS);
                float3 B = normalize(i.bitangentWS);
                float3 N = normalize(i.normalWS);
                float3x3 TBN = float3x3(T,B,N);

                float3 V = normalize(_WorldSpaceCameraPos.xyz - i.positionWS);
                float3 L = normalize(_WorldSpaceLightPos0.xyz - i.positionWS);
                float3 H = normalize(V + L);

                // 光照衰减
                float distance =  length(_WorldSpaceLightPos0.xyz - i.positionWS);
                float attenuation = 1.0 / (distance * distance);
                float radiance = _LightColor0.rgb * attenuation;

                // PBR参数
                float4 albedo = pow(tex2D(_Albedo,i.uv),2.2);
                float4 bump = tex2D(_Normal,i.uv);
                float3 normal = UnpackNormal(bump);
                N = normalize(mul(normal,TBN)); // 从切线空间转换到世界空间
                float roughness = tex2D(_Roughness,i.uv).r;
                float metallic = tex2D(_Metallic,i.uv).r;
                float ao = tex2D(_Ao,i.uv).r;

                float NdotL = max(0.0,dot(N,L));
                float HdotV = max(0.0,dot(H,V));
                float NdotV = max(0.0,dot(N,V));
                float3 R = normalize(reflect(-V,N));

                float3 Lo = float3(0.0,0.0,0.0);

                // 直接光
                float3 F0 = float3(0.04,0.04,0.04);
                F0 = mix(F0,albedo.rgb,metallic);

                float3 F  = fresnelSchlick(HdotV, F0);
                float NDF = DistributionGGX(N, H, roughness);       
                float G   = GeometrySmith(N, V, L, roughness);  

                float3 ks = F;
                float3 kd = 1.0 - ks;
                kd *= 1.0 - metallic;

                float3 _diffuse = kd * albedo.rgb / UNITY_PI;

                float3 nominator  = NDF * G * F;
                float denominator = 4.0 * NdotV * NdotL + 0.001; 
                float3 _specular  = nominator / denominator;  

                Lo += (_diffuse + _specular) * radiance * NdotL;

                // 间接光照
                float3 irradiance = texCUBElod(_Irradiance,float4(N,roughness * 6)).rgb;
                float3 prefilter = texCUBElod(_Prefilter,float4(R,roughness * 6)).rgb;
                float2 lut = tex2D(_LUT,float2(NdotV,roughness)).rg;

                float3 _ks = fresnelSchlickRoughness(NdotV,F0,roughness);
                float3 _kd = 1.0 - _ks;
                _kd *= 1.0 - metallic;

                float3 __diffuse = irradiance * albedo.rgb;

                float3 __specular = prefilter * (_ks * lut.x + lut.y);
                
                float3 _ambient = (kd * __diffuse + __specular) * ao;

                Lo += _ambient;

                Lo = ACESToneMapping(Lo);

                Lo = pow(Lo,1.0 / 2.2);

                return float4(Lo,1.0);
            }
            ENDCG
        }
    }
}
