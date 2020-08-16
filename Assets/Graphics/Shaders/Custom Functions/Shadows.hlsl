void Shadows_float(float3 WorldPos, float3 WorldNormal, float3  WorldView, out float3 AdditionalShadows, out float3 AdditionalLightsDiffuse, out float3 MainLightShadow)
{
	// Shader graph preview defaults;
	AdditionalShadows = 1.0;
	MainLightShadow = 1.0;
	AdditionalLightsDiffuse = 1.0;

	#ifndef SHADERGRAPH_PREVIEW
		//
		// spot light shadow
		//
		half4 shadowCoord = mul(_AdditionalLightsWorldToShadow[0], float4(WorldPos, 1.0));
		ShadowSamplingData a_shadowSamplingData = GetAdditionalLightShadowSamplingData();
		half4 shadowParams = GetAdditionalLightShadowParams(0);

		AdditionalShadows = SampleShadowmap(TEXTURE2D_ARGS(_AdditionalLightsShadowmapTexture, sampler_AdditionalLightsShadowmapTexture), shadowCoord, a_shadowSamplingData, shadowParams, true);

		float3 diffuseColor = 0;

		WorldNormal = normalize(WorldNormal);
		WorldView = SafeNormalize(WorldView);
		int pixelLightCount = GetAdditionalLightsCount();

		for (int i = 0; i < pixelLightCount; ++i)
		{
			Light light = GetAdditionalLight(i, WorldPos);
			float3 attenuatedLightColor = light.color * (light.distanceAttenuation * light.shadowAttenuation);
			diffuseColor += LightingLambert(attenuatedLightColor, light.direction, WorldNormal);
		}

		AdditionalLightsDiffuse = diffuseColor;
		
		//
		// main light
		//
		half4 m_shadowCoord = TransformWorldToShadowCoord(WorldPos);

		ShadowSamplingData m_shadowSamplingData = GetMainLightShadowSamplingData();
		half shadowStrength = GetMainLightShadowStrength();
		MainLightShadow = SampleShadowmap(m_shadowCoord, TEXTURE2D_ARGS(_MainLightShadowmapTexture, sampler_MainLightShadowmapTexture), m_shadowSamplingData, shadowStrength, false);
	#endif
}