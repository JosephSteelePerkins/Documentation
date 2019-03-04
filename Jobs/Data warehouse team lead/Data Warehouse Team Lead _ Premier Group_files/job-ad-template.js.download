$(document).ready(function(){
	// view job, remove empty optional field on job ad template.
	$(".job-ad-option").each(function(){
		var myText = $.trim($(this).children(".job-ad-optional-text").text());
		if ( "to" == myText || "" == myText )
		{
			$(this).hide();
		}
	});
});