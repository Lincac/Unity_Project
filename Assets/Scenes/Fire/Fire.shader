Shader "Fire"
{
    Properties
    {
        _Noise ("Noise", 2D) = "white" {}
        _FireShape ("Fire Shape",2D) = "white" {}

        _SoftEdges ("Soft Edges",float) = 0.1
        _FireSpeed ("Fire Speed",Float) = 0.3

        _ColorLimit ("Color Limit",float) = 0.5
        _FireColorTop ("Fire Top Color",color) = (1,1,1,1)
        _FireColorButtom ("Fire Buttom Color",color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent"}

        blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _Noise;
            float4 _Noise_ST;
            sampler2D _FireShape;
            float4 _FireShape_ST;

            float _SoftEdges;
            float _FireSpeed;

            float _ColorLimit;
            float4 _FireColorButtom;
            float4 _FireColorTop;

            fixed3 lerp3(float3 a,float3 b,float x)
            {
                return float3(
                    lerp(a.x,b.x,x),
                    lerp(a.y,b.y,x),
                    lerp(a.z,b.z,x)
                );
            }

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 noise_uv = i.uv * _Noise_ST.xy + _Noise_ST.zw - float2(0.5,_FireSpeed * _Time.y);
                float2 shape_uv = i.uv * _FireShape_ST.xy + _FireShape_ST.zw;

                fixed noise = tex2D(_Noise, noise_uv).r;
                fixed shape = tex2D(_FireShape,shape_uv).r;
                fixed gradient = 1.0 - i.uv.y;

                fixed dissolve = smoothstep(noise - _SoftEdges,noise,gradient);
                dissolve *= shape;
                
                float limit = step(_ColorLimit,1.0 - i.uv.y) ;

                fixed3 finalColor = lerp3(_FireColorButtom,_FireColorTop,(1.0 - limit));

                return fixed4(finalColor,dissolve);
            }
            ENDCG
        }
    }
}
