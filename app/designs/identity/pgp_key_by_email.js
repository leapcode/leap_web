function(doc) {
  if (doc.type != 'Identity') {
    return;
  }
  if (typeof doc.keys === "object") {
    emit(doc.address, doc.keys["pgp"]);
  }
}
