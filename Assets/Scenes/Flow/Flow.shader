Shader "FLow"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _InnerColor ("Inner Color",Color) = (0.0,0.0,0.0,0.0)
        _OuterColor ("Outer Color",Color) = (1.0,1.0,1.0,1.0)
        _OuterColorIntensity ("Outer Color Intensity",Float) = 1.0
        _FlowColor ("Flow Color",2D) = "white" {}
        _FlowIntensity ("Flow Intensity",Float) = 1.0
        _FlowSpeed ("Flow Speed",Vector) = (0.0,1.0,0.0,0.0)
        _FlowOffset ("Flow Offset",Vector) = (1.0,1.0,0.0,0.0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass{
            ZWrite On
            ColorMask 0
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
            };

            v2f vert(appdata_base v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target{
                return 0;
            }
            ENDCG
        }

        Pass
        {
            ZWrite Off
            Blend SrcAlpha One
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
                float3 normalWS : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _InnerColor;
            float4 _OuterColor;
            float _OuterColorIntensity;
            sampler2D _FlowColor;
            float4 _FlowSpeed;
            float4 _FlowOffset;
            float _FlowIntensity;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.positionWS = mul(unity_ObjectToWorld,v.vertex).xyz;
                o.normalWS = normalize(mul(float4(v.normal,0.0),unity_WorldToObject).xyz);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 N = normalize(i.normalWS);
                float3 V = normalize(_WorldSpaceCameraPos.xyz - i.positionWS);

                float NdotV = saturate(dot(N,V));
                float fresnel = 1.0 - NdotV;

                float4 emiss = tex2D(_MainTex, i.uv);
                emiss = pow(emiss,5.0);
                fresnel = saturate(fresnel + emiss);

                float3 color = lerp(_InnerColor.rgb,_OuterColor.rgb * _OuterColorIntensity,fresnel);

                float2 uv = i.positionWS.xy * _FlowOffset;
                uv += _Time.y * _FlowSpeed.xy;
                float4 flow = tex2D(_FlowColor,uv) * _FlowIntensity;
                fresnel = saturate(fresnel + flow.a);

                float4 final_color = float4(color + flow.rgb,fresnel);
                return final_color;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
