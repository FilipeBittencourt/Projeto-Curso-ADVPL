$(function () {

    
    $('.getClick').on('click', function () {
    //    alert($(this).attr("id"));
    });

    //Pagina de Editar
    $('.checkItemAll').on('click', function () {

        var selector = ".checkItemAll" + $(this).attr("id");

        $(selector).prop('checked', false);

        if ((this.checked ? $(this).val() : "") == "on") {

            $(selector).prop('checked', true);

        }      
      
    });
	
});