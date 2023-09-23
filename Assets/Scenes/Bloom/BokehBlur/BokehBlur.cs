using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BokehBlur : PostProcess
{
    public Shader bokenShader;
    private Material bokenMaterial;
    public Material material
    {
        get
        {
            bokenMaterial = CheckShaderAndCreateMaterial(bokenShader, bokenMaterial);
            return bokenMaterial;
        }
    }

    [Range(8, 128)]
    public int iterations = 8;

    [Range(0.0f, 4.0f)]
    public float size = 0.0f;

    [Range(1, 10)]
    public int downsample = 1;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material != null)
        {
            int w = (int)(source.width / downsample);
            int h = (int)(source.height / downsample);

            RenderTexture pre = RenderTexture.GetTemporary(w, h, 0, source.format);
            pre.filterMode = FilterMode.Bilinear;
            Graphics.Blit(source, pre);

            material.SetInt("_Iteration", iterations);
            material.SetFloat("_Size", size);
            Graphics.Blit(pre, destination, material);

            RenderTexture.ReleaseTemporary(pre);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
