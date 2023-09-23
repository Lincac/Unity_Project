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

    [Range(0, 8)]
    public int blurTimes = 4;

    [Range(0.2f, 3.0f)]
    public float blurSize = 0.6f;

    [Range(4, 8)]
    public int downSampleTimes = 4;

    [Range(0.0f, 3.0f)]
    public float LuminanceThreshold = 0.6f;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(material != null)
        {
            material.SetFloat("_LuminanceThreshold", LuminanceThreshold);

            int width = source.width;
            int height = source.height;

            // Capture Brightness
            RenderTexture buffer0 = RenderTexture.GetTemporary(width, height, 0);
            Graphics.Blit(source, buffer0, material,0);

            // DownSample
            for(int i = 0; i < downSampleTimes; i++)
            {
                width /= 2;
                height /= 2;

                RenderTexture buffer1 = RenderTexture.GetTemporary(width, height, 0);
                Graphics.Blit(buffer0,buffer1,material,1);

                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
            }

            // Blur
            for(int i = 0; i < blurTimes; i++)
            {
                material.SetFloat("_BlurSize",1.0f + i * blurSize);

                RenderTexture buffer1 = RenderTexture.GetTemporary(width, height, 0);
                Graphics.Blit(buffer0, buffer1, material, 3);

                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;

                buffer1 = RenderTexture.GetTemporary(width, height, 0);
                Graphics.Blit(buffer0, buffer1, material, 4);

                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
            }

            // UpSample
            for (int i = 0; i < downSampleTimes; i++)
            {
                width *= 2;
                height *= 2;

                RenderTexture buffer1 = RenderTexture.GetTemporary(width, height, 0);
                Graphics.Blit(buffer0, buffer1, material, 2);

                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
            }

            material.SetTexture("_BloomColor", buffer0);
            Graphics.Blit(source, destination,material,5);
            RenderTexture.ReleaseTemporary(buffer0 );
        }
        else Graphics.Blit(source, destination);
    }
}
