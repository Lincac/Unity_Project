Shader "PostProcess/Kawase"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BlurSize ("Blur Size",Float) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
        	NAME "KAWASEBLUR"

    	    Cull Off ZWrite Off ZTest Always
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _MainTex_TexelSize;
            float _BlurSize;

            v2f vert (appdata_img v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half4 o = 0;
                o += tex2D(_MainTex,i.uv + float2(0.5 + _BlurSize,0.5 + _BlurSize) * _MainTex_TexelSize.xy);
                o += tex2D(_MainTex,i.uv + float2(-0.5 - _BlurSize,0.5 + _BlurSize) * _MainTex_TexelSize.xy);
                o += tex2D(_MainTex,i.uv + float2(-0.5 - _BlurSize,-0.5 - _BlurSize) * _MainTex_TexelSize.xy);
                o += tex2D(_MainTex,i.uv + float2(0.5 + _BlurSize,-0.5 - _BlurSize) * _MainTex_TexelSize.xy);
                o *= 0.25; 
                return o;
            }
            ENDCG
        }
    }
}
