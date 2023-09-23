Shader "PostProcess/Gaussian" 
{
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_BlurSize ("Blur Size", Float) = 1.0
	}
	SubShader {
		CGINCLUDE
		
		#include "UnityCG.cginc"
		
		sampler2D _MainTex;  
		half4 _MainTex_TexelSize;
		float _BlurSize;
		  
		struct v2f {
			float4 pos : SV_POSITION;
			float2 uv : TEXCOORD0;
		};
		  
		v2f vert(appdata_img v) {
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.uv = v.texcoord;
			return o;
		}
		
		fixed4 fragBlurVertical(v2f i) : SV_Target {
			float weight[5] = {0.227027, 0.1945946, 0.1216216, 0.054054, 0.016216};

			float3 sum = tex2D(_MainTex, i.uv).rgb * weight[0];
			for (int it = 1; it < 5; it++) {
				sum += tex2D(_MainTex, i.uv + float2(0.0,_MainTex_TexelSize.y * it) * _BlurSize).rgb * weight[it];
				sum += tex2D(_MainTex, i.uv - float2(0.0,_MainTex_TexelSize.y * it) * _BlurSize).rgb * weight[it];
			}
			
			return fixed4(sum, 1.0);
		}

		fixed4 fragBlurHorizontal(v2f i) : SV_Target {
			float weight[5] = {0.227027, 0.1945946, 0.1216216, 0.054054, 0.016216};

			float3 sum = tex2D(_MainTex, i.uv).rgb * weight[0];
			for (int it = 1; it < 5; it++) {
				sum += tex2D(_MainTex, i.uv + float2(_MainTex_TexelSize.x * it,0.0) * _BlurSize).rgb * weight[it];
				sum += tex2D(_MainTex, i.uv - float2(_MainTex_TexelSize.x * it,0.0) * _BlurSize).rgb * weight[it];
			}
			
			return fixed4(sum, 1.0);
		}
		    
		ENDCG
		
		ZTest Always Cull Off ZWrite Off
		
		Pass {
			NAME "GAUSSIAN_BLUR_VERTICAL"
			
			CGPROGRAM
			#pragma vertex vert  
			#pragma fragment fragBlurVertical
			ENDCG  
		}
		
		Pass {  
			NAME "GAUSSIAN_BLUR_HORIZONTAL"
			
			CGPROGRAM  
			#pragma vertex vert  
			#pragma fragment fragBlurHorizontal
			ENDCG
		}
	} 
}
