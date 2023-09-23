Shader "Phone"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BumpTex ("Normal Texture",2D) = "white" {}
        _HeightTex ("Height Texture",2D) = "white" {}
        _SpecularTex ("Specular Texture",2D) = "white" {}
        _AoTex ("Ao Texture",2D) = "white" {}
        _BumpScale ("Bump Scale",Range(1.0,10.0)) = 1.0
        _HeightScale ("Height Scale",Range(-1.0,1.0)) = 0.1
        _AmbientIntensity ("Ambient Intensity",Range(0.1,1.0)) = 0.1
        _Gloss ("Gloss",Range(8.0,256.0)) = 8.0
        _GlossIntensity ("Gloss Intansity",Range(0.0,10.0)) = 1.0
    }
    SubShader
    {
        CGINCLUDE
		#include "UnityCG.cginc"
		#include "AutoLight.cginc"
        #include "Lighting.cginc"

        struct v2f
        {
            float4 pos : SV_POSITION;
            float2 uv : TEXCOORD0;
            float3 positionWS : TEXCOORD1;
            float3 normalWS : TEXCOORD2;
            float3 tangentWS : TEXCOORD3; // 这个切线是根据uv的方向计算出来的，可能是u也可能是v，根据引擎的规定
            float3 bitangentWS : TEXCOORD4;
			SHADOW_COORDS(5)
        };

        sampler2D _MainTex;
        float4 _MainTex_ST;
        sampler2D _BumpTex;
        sampler2D _HeightTex;
        sampler2D _SpecularTex;
        sampler2D _AoTex;
        float _BumpScale;
        float _HeightScale;
        float _AmbientIntensity;
        float _Gloss;
        float _GlossIntensity;

		float3 ACESToneMapping(float3 x)
		{
			float a = 2.51f;
			float b = 0.03f;
			float c = 2.43f;
			float d = 0.59f;
			float e = 0.14f;
			return saturate((x*(a*x + b)) / (x*(c*x + d) + e));
		};

        float mix(float x,float y,float a)
        {
            return x * (1 - a) + y * a;
        }

        float2 ParallaxMapping(float2 texCoords, float3 viewDir)
        { 
            float numLayers = 20;

            float layerDepth = 1.0 / numLayers;
            float currentLayerDepth = 0.0;
            float2 P = viewDir.xy / viewDir.z * _HeightScale * 0.1; 
            float2 deltaTexCoords = P / numLayers;

            float2  currentTexCoords   = texCoords;
            float currentDepthMapValue = tex2D(_HeightTex, currentTexCoords).r;

            for(int j=0;j<numLayers;j++){
                currentTexCoords -= deltaTexCoords;
                currentDepthMapValue = tex2Dlod(_HeightTex, float4(currentTexCoords,0.0,0.0)).r;
                currentLayerDepth += layerDepth;

                if(currentLayerDepth > currentDepthMapValue) break;
            }

            // 利用前后深度差计算权重比，在pretexcoord和curtexcoord中线性插值
            float2 prevTexCoords = currentTexCoords + deltaTexCoords;

            float afterDepth  = abs(currentDepthMapValue - currentLayerDepth);
            float beforeDepth = abs((1.0 - tex2D(_HeightTex, prevTexCoords).r) - currentLayerDepth);
 
            float weight = afterDepth / (afterDepth + beforeDepth);
            float2 finalTexCoords = prevTexCoords * weight + currentTexCoords * (1.0 - weight);

            return currentTexCoords;    
        }

        v2f vert (appdata_tan v)
        {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
            o.positionWS = mul(unity_ObjectToWorld,v.vertex).xyz;
            o.normalWS = normalize(mul(float4(v.normal,0.0),unity_WorldToObject).xyz); // 逆转置
            o.tangentWS = normalize(mul(unity_ObjectToWorld,float4(v.tangent.xyz,0.0)).xyz);
            o.bitangentWS = normalize(cross(o.normalWS,o.tangentWS.xyz) * v.tangent.w); // 左手定则 w分量决定副切线方向
			TRANSFER_SHADOW(o)
            return o;
        }

        ENDCG

        Pass
        {
            Tags { "LightMode"="ForwardBase" }
            LOD 100

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase 
            // 如果定义了这个multi_compile_fwdbase那么_WorldSpaceLightPos0获得的就是主平行光变量
            // 如果定义了这个multi_compile_fwdadd那么_WorldSpaceLightPos0获得的就是场景中其他光源的变量

            fixed4 frag (v2f i) : SV_Target
            {
                float3 L = normalize(_WorldSpaceLightPos0.xyz);
                float3 V = normalize(_WorldSpaceCameraPos.xyz - i.positionWS);
                float3 H = normalize(L + V);

                float3 T = normalize(i.tangentWS);
                float3 B = normalize(i.bitangentWS);
                float3 N = normalize(i.normalWS);
                float3x3 TBN = float3x3(T,B,N);

                float3 viewDirTS = normalize(mul(TBN,V));
                float2 uv = ParallaxMapping(i.uv,viewDirTS);

                fixed4 col = pow(tex2D(_MainTex, uv),2.2);
                fixed4 spec = tex2D(_SpecularTex,uv);
                float ao = tex2D(_AoTex,uv).r;               
                float4 bump = tex2D(_BumpTex,uv);
                float3 normal = UnpackNormal(bump); // 引擎会对纹理进行压缩，因此需要解压出来
                normal.xy *= _BumpScale;
                normal = normalize(mul(normal,TBN)); // 从切线空间转换到世界空间

                float NdotL = max(dot(normal,L),0.0);
                float NdotH = max(dot(normal,H),0.0);                    

                float3 _ambient = col.rgb * UNITY_LIGHTMODEL_AMBIENT.rgb * _AmbientIntensity;

                // shadow
                float shadow = SHADOW_ATTENUATION(i);

                float3 _diffuse = col.rgb * _LightColor0.rgb * NdotL * shadow;
                
                float3 _specular = spec.rgb * _LightColor0.rgb * pow(NdotH,_Gloss) * _GlossIntensity * shadow;

                float3 finalColor = (_diffuse + _specular + _ambient) * ao;

                // ToneMapping
                finalColor = ACESToneMapping(finalColor);

                // Gamma Correct
                finalColor = pow(finalColor,1.0 / 2.2);

                return fixed4(finalColor,1.0);
            }
            ENDCG
        }
    }

    FallBack "Diffuse"
}
