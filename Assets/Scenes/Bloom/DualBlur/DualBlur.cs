using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DualBlur : PostProcess
{
    public Shader dualShader;
    private Material dualMaterial = null;
    public Material material
    {
        get
        {
            dualMaterial = CheckShaderAndCreateMaterial(dualShader, dualMaterial);
            return dualMaterial;
        }
    }

    [Range(0, 10)]
    public int iterations = 0;

    [Range(0.0f, 4.0f)]
    public float size = 0.0f;

    [Range(1, 4)]
    public int downscaling = 1;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(material != null)
        {
            int w = (int)(source.width / downscaling);
            int h = (int)(source.height / downscaling);

            RenderTexture pre = RenderTexture.GetTemporary(w, h, 0, source.format);
            pre.filterMode = FilterMode.Bilinear;
            Graphics.Blit(source, pre);

            material.SetFloat("_BlurSize", size);

            // downsample
            for (int i = 0; i < iterations; i++)
            {
                w = Mathf.Max(w / 2, 1);
                h = Mathf.Max(h / 2, 1);

                RenderTexture cur = RenderTexture.GetTemporary(w, h, 0, source.format);
                cur.filterMode = FilterMode.Bilinear;
                Graphics.Blit(pre, cur, material, 0);

                RenderTexture.ReleaseTemporary(pre);
                pre = cur;
            }

            // upsample
            for (int i = 0; i < iterations - 1; i++)
            {
                w = Mathf.Min(w * 2, source.width);
                h = Mathf.Min(h * 2, source.height);

                RenderTexture cur = RenderTexture.GetTemporary(w, h, 0, source.format);
                cur.filterMode = FilterMode.Bilinear;
                Graphics.Blit(pre, cur, material, 1);

                RenderTexture.ReleaseTemporary(pre);
                pre = cur;
            }

            Graphics.Blit(pre, destination);
            RenderTexture.ReleaseTemporary(pre);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
