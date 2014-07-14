function(doc) {
  if (doc.type != 'Identity') {
    return;
  }
  if (typeof doc.user_id === "undefined") {
    emit(doc._id, 1);
  }
}
