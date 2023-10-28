Shader "Cloud"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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
            #include "Cloud.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 ro = _WorldSpaceCameraPos.xyz;
                float3 rd = getDir(i.uv);

                float3 bg = getSkyColor(rd);
                float4 finalcolor = float4(bg,0);

                float3 start;
                float3 end;
                if(hitbox(ro,rd,start,end))
                {
                    finalcolor = raymarch(start,end,bg);
                    finalcolor.a = 1.0;

                    //float3 dir = normalize(end - start);
                    //float density = getDensity(start + dir * 0.01);
                    //finalcolor = float4(density.xxx,1.0);
                }

                return finalcolor;
            }
            ENDCG
        }
    }
}
