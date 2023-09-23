using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]
public class PostProcess : MonoBehaviour
{
    [Obsolete]
    protected void CheckResource()
    {
        if(SystemInfo.supportsImageEffects == false || SystemInfo.supportsRenderTextures == false)
        {
            Debug.Log("This platform is not support image effects or render texture");
            enabled = false;
        }
    }

    protected Material CheckShaderAndCreateMaterial(Shader shader, Material material)
    {
        if (shader == null) return null;
        if(shader.isSupported && material && material.shader == shader) return material;

        if (!shader.isSupported) return null;
        else
        {
            material = new Material(shader);
            material.hideFlags = HideFlags.DontSave; // It's temp material
            if (material) return material;
            else return null;
        }
    }

    [Obsolete]
    void Start()
    {
        CheckResource();

        Camera cam = this.GetComponent<Camera>();
        cam.depthTextureMode |= DepthTextureMode.DepthNormals;
    }
}
