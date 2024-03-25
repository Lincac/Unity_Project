using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bloom : PostProcess
{
    public Shader bloomShader;
    private Material bloomMaterial = null;
    public Material material
    {
        get
        {
            bloomMaterial = CheckShaderAndCreateMaterial(bloomShader, bloomMaterial);
            return bloomMaterial;
        }
    }

    [Range(0, 10)]
    public int bloomIntensity = 0;

    [Range(0.0f, 4.0f)]
    public float bloomRange = 0.0f;

    [Range(0.0f, 3.0f)]
    public float LuminanceThreshold = 0.6f;

    [Range(1.0f, 10.0f)]
    public float LuminanceIntensity = 1.0f;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material != null)
        {
            material.SetFloat("_LuminanceThreshold", LuminanceThreshold);

            int width = source.width;
            int height = source.height;

            // Capture Brightness
            RenderTexture buffer0 = RenderTexture.GetTemporary(width, height, 0);
            Graphics.Blit(source, buffer0, material,0);

            // DownSample
            for(int i = 0; i < 4; i++)
            {
                width /= 2;
                height /= 2;

                RenderTexture buffer1 = RenderTexture.GetTemporary(width, height, 0);
                Graphics.Blit(buffer0,buffer1,material,1);

                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
            }

            // Blur
            for (int i = 0; i < bloomIntensity; i++)
            {
                material.SetFloat("_BlurSize", i / 4 + bloomRange);

                RenderTexture buffer1 = RenderTexture.GetTemporary(width, height, 3);
                Graphics.Blit(buffer0, buffer1, material, 3);

                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
            }
            material.SetFloat("_BlurSize", bloomIntensity / 4 + bloomRange);
            RenderTexture buffer3 = RenderTexture.GetTemporary(width, height, 0);
            Graphics.Blit(buffer0, buffer3, material, 3);

            RenderTexture.ReleaseTemporary(buffer0);
            buffer0 = buffer3;

            // UpSample
            for (int i = 0; i < 4; i++)
            {
                width *= 2;
                height *= 2;

                RenderTexture buffer1 = RenderTexture.GetTemporary(width, height, 0);
                Graphics.Blit(buffer0, buffer1, material, 2);

                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
            }

            // combine
            material.SetTexture("_BloomColor", buffer0);
            material.SetFloat("_LuminanceIntensity", LuminanceIntensity);
            Graphics.Blit(source, destination,material,4);
            RenderTexture.ReleaseTemporary(buffer0 );
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
