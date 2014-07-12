function(doc) {
  if (doc.type != 'Identity') {
    return;
  }
  if (typeof doc.cert_fingerprints === "object") {
    for (fp in doc.cert_fingerprints) {
      if (doc.cert_fingerprints.hasOwnProperty(fp)) {
        emit(fp, doc.cert_fingerprints[fp]);
      }
    }
  }
}
