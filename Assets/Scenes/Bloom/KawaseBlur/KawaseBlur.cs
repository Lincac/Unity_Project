using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class KawaseBlur : PostProcess
{
    public Shader kawaseShader;
    private Material kawaseMaterial = null;
    public Material material
    {
        get
        {
            kawaseMaterial = CheckShaderAndCreateMaterial(kawaseShader, kawaseMaterial);
            return kawaseMaterial;
        }
    }

    [Range(0, 10)]
    public int blurIterations = 0;

    [Range(0.0f, 4.0f)]
    public float blurSize = 0.0f;

    [Range(1, 4)]
    public int DownsampleScaling = 1;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(material != null)
        {
            int w = (int)(source.width / DownsampleScaling);
            int h = (int)(source.height / DownsampleScaling);

            RenderTexture buffer0 = RenderTexture.GetTemporary(w, h, 0, source.format);
            buffer0.filterMode = FilterMode.Bilinear;
            RenderTexture buffer1 = RenderTexture.GetTemporary(w, h, 0, source.format);
            buffer1.filterMode = FilterMode.Bilinear;

            Graphics.Blit(source, buffer0);

            for (int i = 0; i < blurIterations; i++)
            {
                material.SetFloat("_BlurSize", i / DownsampleScaling + blurSize);

                if (i % 2 == 0) Graphics.Blit(buffer0, buffer1, material,0);
                else Graphics.Blit(buffer1, buffer0, material,0);
            }

            material.SetFloat("_BlurSize", blurIterations / DownsampleScaling + blurSize);
            if (blurIterations % 2 == 0) Graphics.Blit(buffer0, destination, material);
            else Graphics.Blit(buffer1, destination, material,0);

            RenderTexture.ReleaseTemporary(buffer0);
            RenderTexture.ReleaseTemporary(buffer1);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
