$(document).ready(function() {
  $('form').on('submit',function(e) {
    e.preventDefault();
    $('form').hide();
    var data = $('form').serialize();

    $.ajax({
      method: "POST",
      url: "/",
      data: data
    }).done(function(response) {
      console.log(response);
      $('#status').val('');
      $('form').show();
      $('form').prepend(response.successful);
    });
  });
});
