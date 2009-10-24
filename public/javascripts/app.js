$(function () {
  $('a.delete').click(function() {
    if(confirm('Are you sure?')) {
      $('body').append(jTag('form', "", [jAt('method', 'post'), jAt('action', this.href)]));
      $('form').submit();
      
    }
    return false;
    });
});
