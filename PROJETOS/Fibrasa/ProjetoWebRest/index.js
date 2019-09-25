$.ajaxSetup({
    cache: false
});
$(document).ready(function () {	

	
	$("#cod-barras-produto").val(""); 
    $( "#cod-barras-produto" ).focus();
 
    $("#image-produto, #image-load").hide();
	
    $('#cod-barras-produto').keypress(function (e) {
        $("#image-produto").hide();
		$("#image-load").show();
		 
        if (e.which == 13) {					
            $.ajax({
				url: "http://192.168.200.171:8098/rest/RESTSB1/"+$("#cod-barras-produto").val()+"/"+$('#ddlEmpresa').val()+"/"+$('#ddlFilial').val(),                
               cache: false,
                type: 'GET',
                error: function (data) {                                      
                    alert("Um erro ocorreu na chamada com o Protheus. Favor acionar o suporte.");
					console.log(data);
                },
                success: function (data) {
					
					if(data.response != undefined){
						
						$("#image-produto").show();					
						$("#cod-produto").val(data.response.B1_COD);
						$("#nome-produto").val(data.response.B1_DESC);               
						$("#u-medida").val(data.response.B1_UM);     
						$("#peso-produto").val(data.response.B1_PESO);					
						$("#desc-tecnica-produto").val(data.response.B1_DESCNF1); 
						$('#cod-barras-produto2').val(data.response.B1_CODBAR); 						
						$("#image-load").hide();
						$('#image-produto').attr('src', 'images/'+data.response.B1_COD+'.jpg?'+Date.now()+'');		
							
					}
					else
					{			
						
						$(".inputText").val("");
						$("#image-load").hide();
						$("#image-produto").show();								
						$('#image-produto').attr('src', 'images/sem-imagem.jpg');	
						
					}					

                },
				complete: function () {
					 
					$("#cod-barras-produto").val("");									
					$("#image-produto").each(function(){
						var $image = $(this);
						$.ajax($(this).attr("src")).done(function() {
							//alert(1);
							//$image.addClass("imagedone");
						}).fail(function() { 
						//alert(2);
							$image.attr('src', 'images/sem-imagem.jpg');
						});
					});
				}
				
            });
        }
      });	 
});
 