using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class Blur : PostProcess
{
    public Shader blurShader;
    private Material blurMaterial = null;
    public Material material
    {
        get
        {
            blurMaterial = CheckShaderAndCreateMaterial(blurShader, blurMaterial);
            return blurMaterial; 
        }
    }

    [Range(0, 10)]
    public int blurIterations = 0;

    [Range(0.0f, 4.0f)]
    public float blurSize = 0.0f;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(material != null)
        {
            RenderTexture buffer0 = RenderTexture.GetTemporary(source.width, source.height,0,source.format);
            Graphics.Blit(source, buffer0);

            for(int i= 0; i < blurIterations; i++)
            {
                material.SetFloat("_BlurSize", 1.0f + blurSize);
                RenderTexture buffer1 = RenderTexture.GetTemporary(source.width,source.height,0,source.format);
                Graphics.Blit(buffer0, buffer1, material, 0);

                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;

                buffer1 = RenderTexture.GetTemporary(source.width, source.width, 0, source.format);
                Graphics.Blit(buffer0,buffer1, material, 1);

                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
            }

            Graphics.Blit(buffer0,destination);
            RenderTexture.ReleaseTemporary(buffer0); 
        }else
        {
            Graphics.Blit(source, destination);
        }
    }
}
