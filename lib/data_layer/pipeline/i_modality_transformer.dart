import '../vector/extracted_content.dart';

abstract interface class IModalityTransformer {
  String get id;
  String get version;
  String get inputModality;
  String get outputModality;

  Future<ExtractedContent> transform(ExtractedContent input);
}
