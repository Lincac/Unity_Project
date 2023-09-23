Shader "Vine"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _VineSize ("Vine Size",Range(0.0,10.0)) = 0.0
        _VineGrow ("Vine Grow",Range(0.0,1.0)) = 0.0
        _VineGrowMax ("Vine Grow Max",Range(1.0,2.0)) = 1.0
        _VineGrowMin ("Vine Grow Min",Range(0.0,1.0)) = 0.0
        _VineTip ("Vine Tip",Float) = 0.0
    }
    SubShader
    {
        Tags { "Queue"="AlphaTest" }
        LOD 100

        Pass
        {
            Cull Off
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
            float _VineSize;
            float _VineGrow;
            float _VineTip;
            float _VineGrowMax;
            float _VineGrowMin;

            v2f vert (appdata_base v)
            {
                v2f o;

                float Gorwing = smoothstep(_VineGrowMin,_VineGrowMax,1.0 - (_VineGrow - v.texcoord.y));
                float3 vine_grow = v.normal * Gorwing * _VineTip * 0.1;
                float3 vine_size = v.normal * _VineSize * 0.1;
                float3 vertex = v.vertex + vine_size + vine_grow;
                o.pos = UnityObjectToClipPos(vertex);
                o.uv = v.texcoord;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                clip(_VineGrow - i.uv.y); // clip ungrow
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
