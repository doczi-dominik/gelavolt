import kha.graphics4.BlendingFactor;
import kha.Shaders;
import kha.graphics4.VertexStructure;
import kha.graphics4.PipelineState;

class Pipelines {
	public static var FADE_TO_WHITE(default, null): PipelineState;

	public static function init() {
		final emptryStructure = new VertexStructure();
		emptryStructure.add("vertexPosition", Float3);
		emptryStructure.add("vertexUV", Float2);
		emptryStructure.add("vertexColor", Float4);

		FADE_TO_WHITE = new PipelineState();
		FADE_TO_WHITE.inputLayout = [emptryStructure];
		FADE_TO_WHITE.vertexShader = Shaders.painter_image_vert;
		FADE_TO_WHITE.fragmentShader = Shaders.fade_to_white_frag;
		FADE_TO_WHITE.blendSource = BlendingFactor.BlendOne;
		FADE_TO_WHITE.blendDestination = BlendingFactor.InverseSourceAlpha;
		FADE_TO_WHITE.alphaBlendSource = BlendingFactor.SourceAlpha;
		FADE_TO_WHITE.alphaBlendDestination = BlendingFactor.SourceAlpha;
		FADE_TO_WHITE.compile();
	}
}
