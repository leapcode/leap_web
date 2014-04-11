// TODO: This view is only used in tests--should we keep it?
function(doc) {
  var arr = {}
  if (doc['type'] == 'Ticket' && doc.comments) {
    doc.comments.forEach(function(comment){
      if (comment.posted_by && !arr[comment.posted_by]) {
        //don't add duplicates
        arr[comment.posted_by] = true;
        emit(comment.posted_by, 1);
      }
    });
  }
}
