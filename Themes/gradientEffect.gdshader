shader_type canvas_item;

uniform sampler2D gradient;

/*uniform float scale : hint_range(0.1, 10) = 2.0;*/
uniform float opacity_scale : hint_range(0, 1) = 1.0;

/*uniform float flashState : hint_range(0,1) = 0.5;*/

/*uniform vec4 color : source_color;*/

void fragment() {
	
	vec2 distortedUV = UV;
	
	/*vec4 pixelColor = texture(TEXTURE, distortedUV);*/
	vec4 pixelColor = texture(TEXTURE, UV);
	vec4 gradientColor = texture(gradient, UV) * opacity_scale;
	
	/*float brightness = (pixelColor.r + pixelColor.g + pixelColor.b) / 3.0;*/
	
	/*vec4 grayScale = vec4(brightness, brightness, brightness, pixelColor.a);*/

	
	/*COLOR = pixelColor * scale;*/
	/*COLOR = grayScale * scale;*/
	/*distortedUV.x += distortedUV.y * 0.7  * scale;*/
	/*COLOR = mix(pixelColor, color, flashState) * scale;*/
	COLOR.a *= opacity_scale;
	COLOR = mix(pixelColor, gradientColor, 0.7);
	
}
