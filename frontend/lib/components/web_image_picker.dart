import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

class WebImagePicker {
  Future<Uint8List?> pickImage() async {
    final completer = Completer<Uint8List?>();
    
    final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files?.isEmpty ?? true) {
        completer.complete(null);
        return;
      }

      final reader = html.FileReader();
      reader.readAsArrayBuffer(files!.first);

      reader.onLoadEnd.listen((e) {
        completer.complete(reader.result as Uint8List?);
      });
    });

    return completer.future;
  }
}