
$(function () {

	$('.btn-novo-visitante').on('click',
		function () {
			AdicionarVisitante('tabela-novo-visitante');
		}
	);



	$("#tabela-novo-visitante").on("click", ".btn-delete-visitante",
		function () {
			var tr = $(this).closest('tr');
			tr.fadeOut(100, function () {
				tr.remove();
			});
		}
	);



	$("#tabela-novo-visitante").on("click", ".btn-delete-visitante-list",
		function () {
			RemoveVisitante(this)
		}
	);

});


var loop = $('#tabela-novo-visitante tr').length - 1;;
function AdicionarVisitante(tabela) {

	var tipo = ['text', 'text', 'html'];
	var nome = ['List[' + loop + '].Nome', 'List[' + loop +'].CPF', ''];
	var id = ['Nome' + loop, 'CPF' + loop, ''];
	var valor = ["", "", '<input name="List[' + loop + '].SolicitacaoServicoFornecedorID" type="hidden" value=""><a href="javascript:void(0)" class="btn btn-icon fs-xl waves-effect waves-themed btn-delete-visitante" ><i class="fal fa-trash-alt color-fusion-300"></i></a>'];
	var estilo = ["form-control", "form-control", ""];
	var estiloCell = ["", "", "center"];
	var colspanCell = ["", "", ""];
	var outros = ["", "", ""];
	addRow(tabela, tipo, nome, id, valor, estilo, outros, estiloCell, colspanCell, colspanCell);

	$('input[name="List[' + loop + '].SolicitacaoServicoFornecedorID"]').val($('input[name="ID"]').val());

	loop++;

	
}


function RemoveVisitante(el) {

	var Id = $(el).closest('tr').find('input[name=SolicitacaoServicoFornecedorVisitanteID]').val();
	
	Swal.fire(
		{
			text: "Deseja remover o visitante?",
			type: "warning",
			showCancelButton: true,
			confirmButtonText: "Sim",
			cancelButtonText: "Não"
		}).then(function (result) {
			if (result.value) {

				$('#preloader').removeClass('hide');
				$('#preloader div#status').html('Aguarde...');

				$.get(
					'/Compra/SolicitacaoServicoFornecedorVisitante/Remover',
					{ Id: Id },
					function (d) {

						$('#preloader').addClass('hide');

						var type = ""
						var text = ""

						if (d.ok) {
							type = "success";
							text = "Visitante removido com sucesso.";

							var tr = $(el).closest('tr');
							tr.fadeOut(100, function () {
								tr.remove();
							});

						} else {
							type = "error"
							text = d.mensagem
						}

						Swal.fire({
							type: type,
							title: "",
							text: text,
						});

					}
				);
			}
		});
}
