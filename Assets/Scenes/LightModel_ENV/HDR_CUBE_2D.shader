Shader "HDR_CUBE_2D"
{
    Properties
    {
        _CUBETex ("Texture", 2D) = "white" {}
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

            sampler2D _CUBETex;
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

            float2 DirToUV(float3 dir){
                float3 normalizedCoords = normalize(dir);
				float latitude = acos(normalizedCoords.y);
				float longitude = atan2(normalizedCoords.z, normalizedCoords.x);
				float2 sphereCoords = float2(longitude, latitude) * float2(0.5 / UNITY_PI, 1.0 / UNITY_PI);
				float2 uv_panorama =  float2(0.5, 1.0) - sphereCoords;
                
                return uv_panorama;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 V = normalize(_WorldSpaceCameraPos.xyz - i.positionWS);
                float3 N = normalize(i.normalWS);
                float3 R = normalize(reflect(-V,N));

                float2 uv = DirToUV(R);
                float4 hdr = tex2D(_CUBETex,uv);

                float3 col = DecodeHDR(hdr,_CUBETex_HDR);
                col = ACESToneMapping(col);

                return fixed4(col,1.0);
            }
            ENDCG
        }
    }
}
