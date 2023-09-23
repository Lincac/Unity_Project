Shader "Character"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _RampTex ("Ramp Texture",2D) = "white" {}
    }
    SubShader
    {

        /*
        Pass 
        {
            NAME "OUTLINE"
            Cull Front

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
		    #include "UnityCG.cginc"

            float _LineWidth;
            float4 _LineColor;

            struct v2f{
                float4 pos : SV_POSITION;
            };

            v2f vert(appdata_base v){
                v2f o;
                float4 pos = mul(UNITY_MATRIX_MV,v.vertex);
                float3 normal = mul((float3x3)UNITY_MATRIX_IT_MV,v.normal);
                normal.z = -0.5;
                pos = pos + float4(normalize(normal),0.0) * _LineWidth * 0.01;
                o.pos = mul(UNITY_MATRIX_P,pos);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target{
                return fixed4(_LineColor.rgb,1.0);
            }

            ENDCG
        }
        */

        Pass
        {
            Tags { "RenderType"="Opaque" "LightMode"="ForwardBase"}
            LOD 100
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
		    #include "UnityCG.cginc"
		    #include "AutoLight.cginc"
            #include "Lighting.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
                float3 normalWS : TEXCOORD2;
                SHADOW_COORDS(5)
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _RampTex;

            v2f vert (appdata_tan v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.positionWS = mul(unity_ObjectToWorld,v.vertex).xyz;
                o.normalWS = normalize(mul(float4(v.normal,0.0),unity_WorldToObject).xyz);
                TRANSFER_SHADOW(o);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 L = normalize(_WorldSpaceLightPos0.xyz);
                float3 V = normalize(_WorldSpaceCameraPos.xyz - i.positionWS);
                float3 N = normalize(i.normalWS);
                float3 H = normalize(L + V);

                // texture
                float3 albedo = tex2D(_MainTex,i.uv).rgb;

                float NdotL = max(0.0,dot(N,L));

                float shadow = SHADOW_ATTENUATION(i);

                float3 _ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;

                float3 _diffuse = albedo * _LightColor0.rgb * NdotL;

                float3 finalColor = _diffuse + _ambient;

                return fixed4(finalColor,1.0);
            }
            ENDCG
        }
    }

    FallBack "Diffuse"
}
