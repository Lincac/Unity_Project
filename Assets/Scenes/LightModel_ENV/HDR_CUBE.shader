Shader "HDR_CUBE"
{
    Properties
    {
        _CUBETex ("Texture", CUBE) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            #define PI 3.1415926

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 positionWS : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
            };

            samplerCUBE _CUBETex;
            float4 _CUBETex_HDR;

		    float3 ACESToneMapping(float3 x)
		    {
			    float a = 2.51f;
			    float b = 0.03f;
			    float c = 2.43f;
			    float d = 0.59f;
			    float e = 0.14f;
			    return saturate((x*(a*x + b)) / (x*(c*x + d) + e));
		    };

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.positionWS = mul(unity_ObjectToWorld,v.vertex).xyz;
                o.normalWS = normalize(mul(float4(v.normal,0.0),unity_WorldToObject).xyz);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 V = normalize(_WorldSpaceCameraPos.xyz - i.positionWS);
                float3 N = normalize(i.normalWS);
                float3 R = normalize(reflect(-V,N));

                float4 hdr = texCUBE(_CUBETex,R);
                float3 col = DecodeHDR(hdr,_CUBETex_HDR); // 防止设备不支持HDR导致数据出错

               col = ACESToneMapping(col);

                return fixed4(col,1.0);
            }
            ENDCG
        }
    }
}
