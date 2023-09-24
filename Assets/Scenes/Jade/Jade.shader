Shader "Unlit/Jade"
{
    Properties
    {
        _BaseColor ("Base Color",Color) = (1,1,1,1)
        _Intensity ("Intensity",Range(0.1,1.0)) = 1.0
        _TransIntensity ("Color Intensity",Range(0.0,10.0)) = 1.0
        _GlossIntensity ("Gloss Intensity",Range(1.0,10.0)) = 1.0
        _Thickness ("Thickness",2D) = "white" {}
        _CubeMap  ("Cube",Cube) = "whitew" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "LightMode"="ForwardBase"}
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
                float3 normalWS : TEXCOORD2;
            };

            float4 _BaseColor;
            float _Intensity;
            float _TransIntensity;
            float _GlossIntensity;
            sampler2D _Thickness;
            samplerCUBE _CubeMap;
            float4 _CubeMap_HDR;

            float3 ACESToneMapping(float3 x)
		    {
			    float a = 2.51f;
			    float b = 0.03f;
			    float c = 2.43f;
			    float d = 0.59f;
			    float e = 0.14f;
			    return saturate((x*(a*x + b)) / (x*(c*x + d) + e));
		    }

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                o.positionWS = mul(unity_ObjectToWorld,v.vertex).xyz;
                o.normalWS = normalize(mul(float4(v.normal,0.0),unity_WorldToObject).xyz);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 V = normalize(_WorldSpaceCameraPos.xyz - i.positionWS);
                float3 L = normalize(_WorldSpaceLightPos0.xyz);
                float3 N = normalize(i.normalWS);

                // 漫反射光
                float NdotL = max(0.0,dot(N,L));
                float3 _diffColor = _BaseColor.rgb * _LightColor0.rgb * NdotL;

                // 透射光
                float thickness = 1.0 - tex2D(_Thickness,i.uv).r;
                float3 transN = normalize(-L + N);
                float VdotT = max(dot(V,transN),0.0);
                VdotT = max(0.0, pow(VdotT,_Intensity));
                float3 _transColor = _BaseColor.rgb * _LightColor0.rgb * VdotT * thickness * _TransIntensity;

                // 光泽
                float3 R = reflect(-V,N);
                float4 hdr = texCUBE(_CubeMap,R);
                float3 env = DecodeHDR(hdr,_CubeMap_HDR);
                float NdotV = max(0.0,dot(N,V));
                float fresnel = 1.0 - NdotV;
                float3 glossColor = env * _BaseColor.rgb * fresnel * _GlossIntensity;

                float3 finalColor = _diffColor + _transColor + glossColor;

                // Tone Mapping
                float3 toneMapping = ACESToneMapping(finalColor);

                // gamma
                float3 gamma = pow(toneMapping, 1.0 / 2.2);

                return float4(gamma,1.0);
            }
            ENDCG
        }
    }

    FallBack "Diffuse"
}
