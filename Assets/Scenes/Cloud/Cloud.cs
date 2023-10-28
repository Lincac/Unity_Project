using UnityEngine;
using System.Collections;

[ExecuteInEditMode, ImageEffectAllowedInSceneView]
public class cloud : PostProcess
{
    public Shader cloudShader;
    private Material cloudMaterial = null;
    public Material material
    {
        get
        {
            cloudMaterial = CheckShaderAndCreateMaterial(cloudShader, cloudMaterial);
            return cloudMaterial;
        }
    }

    public GameObject box = null;
    public Texture3D cloudShape = null;
    public Texture3D cloudDetail = null;
    public Texture2D cloudCoverage = null;

    [Range(0.0f, 1.0f)]
    public float cloudType = 1.0f;

    [Range(-10.0f, 10.0f)]
    public float cloudFactor = 1.0f;

    [Range(1.0f,10.0f)]
    public float lightIntensity = 1.0f;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material != null && box != null)
        {
            Camera cam = Camera.current;
            material.SetMatrix("pro_i", cam.projectionMatrix.inverse);
            material.SetMatrix("vie_i", cam.cameraToWorldMatrix);

            Vector3 box_pos = box.GetComponent<Transform>().position;
            Vector3 box_sca = box.GetComponent<Transform>().localScale;

            Vector3 box_min = box_pos - box_sca / 2.0f;
            Vector3 box_max = box_pos + box_sca / 2.0f;
            material.SetVector("box_min", box_min);
            material.SetVector("box_max", box_max);

            material.SetTexture("_cloudShape", cloudShape);
            material.SetTexture("_cloudDetail", cloudDetail);
            material.SetTexture("_cloudCoverage", cloudCoverage);

            material.SetFloat("_cloudType", cloudType);
            material.SetFloat("_cloudFactor", cloudFactor);
            material.SetFloat("_lightIntensity", lightIntensity);

            Graphics.Blit(source, destination, material);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}

