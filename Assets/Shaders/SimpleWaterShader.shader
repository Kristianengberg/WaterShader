// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/SimpleWater" {
Properties {
	//_WaveScale ("Wave scale", Range (0,10)) = 1
	//_Amplitude ("Amplitude", Range (0,10)) = 1
	_Fresnel ("Fresnel (A) ", 2D) = "gray" {}
	_BumpMap ("Normalmap ", 2D) = "bump" {}
	//_WaveSpeed ("Wave speed (map1 x,y; map2 x,y)", Vector) = (19,9,-16,-7)
	_ReflectiveColor ("Reflective color (RGB) fresnel (A) ", 2D) = "" {}
	_HorizonColor ("Simple water horizon color", COLOR)  = ( .172, .463, .435, 1)

}

Subshader {
	Tags { "WaterMode"="Refractive" "RenderType"="Opaque" }


	Pass {

CGPROGRAM
#pragma vertex vert
#pragma fragment frag


#include "UnityCG.cginc"

uniform float4 _WaveSpeed;
uniform float4 _WaveScale;
uniform float4 _WaveOffset;
uniform float4 _Amplitude;


struct appdata {
	float4 vertex : POSITION;
	float3 normal : NORMAL;
};

struct v2f {
	float4 pos : SV_POSITION;
	float2 bumpuv0 : TEXCOORD0;
	float2 bumpuv1 : TEXCOORD1;
	float3 viewDir : TEXCOORD2;

	UNITY_FOG_COORDS(4)
};

v2f vert(appdata v)
{
	v2f o;
	o.pos = UnityObjectToClipPos(v.vertex);

	float4 temp;
	float4 wpos = mul (unity_ObjectToWorld, v.vertex);

	temp.xyzw = (v.vertex.xzxz + _Time[0]);

	o.bumpuv0 = temp.xy;
	o.bumpuv1 = temp.wz;
	
	o.viewDir.xzy = WorldSpaceViewDir(v.vertex);


	
	UNITY_TRANSFER_FOG(o,o.pos);
	return o;
}



uniform float4 _HorizonColor;

sampler2D _BumpMap;

sampler2D _ReflectiveColor;

half4 frag( v2f i ) : SV_Target
{
	i.viewDir = normalize(i.viewDir);

	half3 bump1 = UnpackNormal(tex2D( _BumpMap, i.bumpuv0 )).rgb;
	half3 bump2 = UnpackNormal(tex2D( _BumpMap, i.bumpuv1 )).rgb;
	half3 bump = (bump1 + bump2) * 0.5;
	

	half fresnelFac = dot( i.viewDir, bump );

	half4 color;


	half4 water = tex2D( _ReflectiveColor, float2(fresnelFac,fresnelFac) );
	color.rgb = lerp( water.rgb, _HorizonColor.rgb, water.a );
	color.a = _HorizonColor.a;

	UNITY_APPLY_FOG(i.fogCoord, color);
	return color;
}
ENDCG

	}
}

}
