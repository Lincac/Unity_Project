Shader "SSAO"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _SSAOTexture ("Ao",2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        CGINCLUDE

        #include "SSAO.cginc"

        sampler2D _MainTex;
        float4 _MainTex_TexelSize;
        sampler2D _SSAOTexture;

        ENDCG

        Pass { 
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {   
                float3 viewNormal = GetViewNormal(i.uv);
                float3 viewPosition = GetViewPos(i.uv);
                float3 noiseVec = normalize(NoiseInXY(i.uv));

                float3 tangent = normalize(noiseVec - viewNormal * dot(noiseVec,viewNormal));
                float3 bitangent = cross(viewNormal,tangent);
                float3x3 TBN = float3x3(tangent,bitangent,viewNormal);

                float radius = 1.0;
                float occlusion = 0.0;
                for(int j=0;j<64;j++){
                    float3 vec = RandomVec(j * i.uv);
                    float scale = float(j) / 64.0;
                    scale = lerp(0.01, 1.0, pow(scale,3.0));
                    vec *= scale;

                    float3 _sample = mul(vec,TBN);
                    _sample = viewPosition + _sample * radius;

                    float4 _offset = float4(_sample, 1.0);
                    _offset = mul(unity_CameraProjection,_offset); 
                    _offset.xyz /= _offset.w;
                    _offset.xyz = _offset.xyz * 0.5 + 0.5; 

                    float _sampleDepth = -GetViewLinearDepth(_offset.xy);

                    float check = smoothstep(0.0, 1.0, radius / abs(viewPosition.z - _sampleDepth ));
                    occlusion += (_sampleDepth >= _sample.z ? 1.0 : 0.0) * check;
                }
                occlusion = 1.0 - (occlusion / 64.0);
                    
                return float4(occlusion.xxx,1.0);
            }
            ENDCG
        }

        UsePass "PostProcess/Blur/GAUSSIAN_BLUR_VERTICAL"

        UsePass "PostProcess/Blur/GAUSSIAN_BLUR_HORIZONTAL"

        Pass{
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
        
            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target{
                return fixed4(tex2D(_MainTex,i.uv).rgb * tex2D(_SSAOTexture,i.uv).r,1.0);
            }

            ENDCG

        }
    }
}
