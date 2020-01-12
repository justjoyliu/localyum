$(function() {
  $("#hostevent_startdate").datepicker({
  		format: 'yyyy-mm-dd'
  	});

  $(".popright").tooltip({placement:'right'}); 

  $('#evts_index_filter').submit(function () {
    $.get(this.action, $(this).serialize(), null, 'script');
    return false;
  });

});


jQuery(document).ready(
  function($){
    //portfolio - show link
    $('.fdw-background').hover(
        function () {
            $(this).animate({opacity:'1'});
        },
        function () {
            $(this).animate({opacity:'0'});
        }
    );

    $('.flexslider').flexslider({
      animation: "slide",
      slideshow: false
      // controlNav: "thumbnails"
    }); 
});


$(document).click(function() {
  $('#question_inner').hide();
  $('#explore_inner').hide();
  $('#user_nav_inner').hide();
});

$(document).ready(function() {
  $('#explore_nav').click(function(e) {
    $('#explore_inner').slideToggle("fast");
    $('#question_inner').hide();
    $('#user_nav_inner').hide();
    $('#user_li_nav_inner').hide();
    $('#user_su_nav_inner').hide();
    e.stopPropagation();
    return false;
  });

  $('#question_nav').click(function(e) {
    $('#question_inner').slideToggle("fast");
    $('#explore_inner').hide();
    $('#user_nav_inner').hide();
    $('#user_li_nav_inner').hide();
    $('#user_su_nav_inner').hide();
    e.stopPropagation();
    return false;
  });

  $('#user_nav').click(function(e) {
    $('#user_nav_inner').slideToggle("fast");
    $('#question_inner').hide();
    $('#explore_inner').hide();
    e.stopPropagation();
    return false;
  });

  $('#user_li_nav').click(function() {
    $('#user_li_nav_inner').toggle("fast");
    $('#question_inner').hide();
    $('#user_nav_inner').hide();
    $('#user_su_nav_inner').hide();
  });

  $('#user_su_nav').click(function() {
    $('#user_su_nav_inner').toggle("fast");
    $('#question_inner').hide();
    $('#user_nav_inner').hide();
    $('#user_li_nav_inner').hide();
  });
});

// for ie placeholder
$(document).ready(function(){

  if(!Modernizr.input.placeholder){

    $('[placeholder]').focus(function() {
      var input = $(this);
      if (input.val() == input.attr('placeholder')) {
      input.val('');
      input.removeClass('placeholder');
      }
    }).blur(function() {
      var input = $(this);
      if (input.val() == '' || input.val() == input.attr('placeholder')) {
      input.addClass('placeholder');
      input.val(input.attr('placeholder'));
      }
    }).blur();
    $('[placeholder]').parents('form').submit(function() {
      $(this).find('[placeholder]').each(function() {
      var input = $(this);
      if (input.val() == input.attr('placeholder')) {
        input.val('');
      }
      })
    });

  }
});