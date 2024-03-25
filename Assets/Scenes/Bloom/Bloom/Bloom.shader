Shader "PostProcess/Bloom"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BloomColor ("Bloom Color",2D) = "white" {}
        _LuminanceThreshold ("Luminance Threshold",Float) = 0.6
        _LuminanceIntensity ("Luminance Intensity",Float) = 1.0
    }
    SubShader
    {
        CGINCLUDE
        #include "UnityCG.cginc"

        struct appdata
        {
            float4 vertex : POSITION;
            float2 texcoord : TEXCOORD0;
        };

        struct v2f
        {
            float4 pos : SV_POSITION;
            float2 uv : TEXCOORD0;
        };

        sampler2D _MainTex;
        float4 _MainTex_TexelSize;
        sampler2D _BloomColor;
        float _LuminanceThreshold;
        float _LuminanceIntensity;

        v2f vert (appdata v)
        {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = v.texcoord;
            return o;
        }
    
        ENDCG

        Pass
        {
            NAME "CaptureBrightness"

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            float luminance(float4 color){
                return 0.2126 * color.r + 0.7152 * color.b + 0.0722 * color.b;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                float lum = clamp(luminance(col) - _LuminanceThreshold,0.0,1.0);
                return fixed4(col.rgb * lum,1.0);
            }
            ENDCG
        }

        Pass{
            NAME "DownSample"

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            float3 DownSample(float2 uv){
                float3 outColor = float3(0.0,0.0,0.0);

	            float2 halfpixel = 0.5 * float2(_MainTex_TexelSize.x, _MainTex_TexelSize.y);
	            float2 oneepixel = 1.0 * float2(_MainTex_TexelSize.x, _MainTex_TexelSize.y);    

	            outColor += (1.0/8.0) * tex2D(_MainTex, uv + float2(-halfpixel.x, -halfpixel.y) );
	            outColor += (1.0/8.0) * tex2D(_MainTex, uv + float2(+halfpixel.x, +halfpixel.y) );
	            outColor += (1.0/8.0) * tex2D(_MainTex, uv + float2(+halfpixel.x, -halfpixel.y) );
	            outColor += (1.0/8.0) * tex2D(_MainTex, uv + float2(-halfpixel.x, +halfpixel.y) );

	            outColor += (1.0/18.0) * tex2D(_MainTex, uv);
	            outColor += (1.0/18.0) * tex2D(_MainTex, uv + float2(+oneepixel.x, 0.0) );
	            outColor += (1.0/18.0) * tex2D(_MainTex, uv + float2(-oneepixel.x, 0.0) );
	            outColor += (1.0/18.0) * tex2D(_MainTex, uv + float2(0.0, +oneepixel.y) );
	            outColor += (1.0/18.0) * tex2D(_MainTex, uv + float2(0.0, -oneepixel.y) );
	            outColor += (1.0/18.0) * tex2D(_MainTex, uv + float2(+oneepixel.x, +oneepixel.y) );
	            outColor += (1.0/18.0) * tex2D(_MainTex, uv + float2(-oneepixel.x, +oneepixel.y) );
	            outColor += (1.0/18.0) * tex2D(_MainTex, uv + float2(+oneepixel.x, -oneepixel.y) );
	            outColor += (1.0/18.0) * tex2D(_MainTex, uv + float2(-oneepixel.x, -oneepixel.y) );

                return outColor;
            }

            fixed4 frag(v2f i) : SV_Target{
                float3 outColor = DownSample(i.uv);
                return fixed4(outColor,1.0f);
            }

            ENDCG
        }

        Pass{
            NAME "UpSample"

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            float3 UpSample(float2 uv){
                float3 outColor = float3(0.0,0.0,0.0);

	            float2 oneepixel = 1.0 * float2(_MainTex_TexelSize.x, _MainTex_TexelSize.y);    

	            outColor += (1.0/4.0) * tex2D(_MainTex, uv);
	            outColor += (1.0/8.0) * tex2D(_MainTex, uv + float2(+oneepixel.x, 0.0) );
	            outColor += (1.0/8.0) * tex2D(_MainTex, uv + float2(-oneepixel.x, 0.0) );
	            outColor += (1.0/8.0) * tex2D(_MainTex, uv + float2(0.0, +oneepixel.y) );
	            outColor += (1.0/8.0) * tex2D(_MainTex, uv + float2(0.0, -oneepixel.y) );
	            outColor += (1.0/16.0) * tex2D(_MainTex, uv + float2(+oneepixel.x, +oneepixel.y) );
	            outColor += (1.0/16.0) * tex2D(_MainTex, uv + float2(-oneepixel.x, +oneepixel.y) );
	            outColor += (1.0/16.0) * tex2D(_MainTex, uv + float2(+oneepixel.x, -oneepixel.y) );
	            outColor += (1.0/16.0) * tex2D(_MainTex, uv + float2(-oneepixel.x, -oneepixel.y) );

                return outColor;
            }

            fixed4 frag(v2f i) : SV_Target{
                float3 outColor = UpSample(i.uv);
                return fixed4(outColor,1.0f);
            }

            ENDCG
        }

        UsePass "PostProcess/Kawase/KAWASEBLUR"

        Pass{
            NAME "Combine"

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            fixed4 frag(v2f i) : SV_Target{
                return tex2D(_MainTex,i.uv) + tex2D(_BloomColor,i.uv) * _LuminanceIntensity;
            }
            ENDCG
        }
    }
}
