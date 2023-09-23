using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ImageEffectAllowedInSceneView]
public class SSAO : PostProcess
{
    public Shader ssaoShader;
    private Material ssaoMaterial = null;
    public Material material
    {
        get
        {
            ssaoMaterial = CheckShaderAndCreateMaterial(ssaoShader, ssaoMaterial);
            return ssaoMaterial;
        }
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(material != null)
        {
            RenderTexture buffer0 = RenderTexture.GetTemporary(source.width, source.height, 0, source.format);
            buffer0.filterMode = FilterMode.Bilinear;
            
            // SSAO
            Graphics.Blit(source,buffer0 , material,0);

            // Blur
            for(int i = 0; i < 2; i++)
            {
                material.SetFloat("_BlurSize", 1.0f);

                RenderTexture buffer1 = RenderTexture.GetTemporary(source.width, source.height, 0);
                Graphics.Blit(buffer0, buffer1, material, 1);

                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;

                buffer1 = RenderTexture.GetTemporary(source.width, source.height, 0);
                Graphics.Blit(buffer0, buffer1, material, 2);

                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
            }

            material.SetTexture("_SSAOTexture", buffer0);
            Graphics.Blit(source, destination,material,3);

            RenderTexture.ReleaseTemporary(buffer0);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
