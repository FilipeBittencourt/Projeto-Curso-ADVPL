$(function () {

	$('.btn-salvar-ss').on('click', function () {

		if ($("select[name='DataValidade']").val() == "") {
			alert("O campo 'Data Validade Orçamento' de obrigatório.");
			return;
		} 


		$('#preloader').removeClass('hide');
		$('#preloader div#status').html('Aguarde...');


		$("form[name=FormCad]").submit();

	});

	$('.btn-selecionar-cotacao').on('click', function () {
		var el = $(this).closest('div');
		if ($(this).hasClass('btn-primary')) {
			$(this).removeClass('btn-primary').addClass('btn-success');
			$(el).find('input.aprovar').val('true')
			$(el).closest('div.card-body').find('.habilitar-observacao').addClass('hide')

			$(this).text('Desmarcar');

		} else {
			$(this).removeClass('btn-success').addClass('btn-primary');
			$(el).find('input[name=Aprovado]').val('false')
			$(this).text('Marcar');
			$(el).closest('div.card-body').find('.habilitar-observacao').removeClass('hide')

		}
	});

	$('.btn-escolher-cotacao').on('click', function () {
		var el = $('input.aprovar');
		var cont = 0;
		for (var i = 0; i < el.length; i++) {
			var val = $(el[i]).val();
			if (val == "true") {
				cont++;
			}
		}
		if (cont == 0) {
			alert("Selecione pelo menos uma cotação para prosseguir.");
			return;
		}
		CheckFornecedorCadastrado();
	});


	$("input.calc-preco, input.calc-total, input.calc-quantidade").inputmask('currency', {
		"autoUnmask": true,
		radixPoint: ",",
		groupSeparator: ".",
		allowMinus: false,
		prefix: '',
		//digits: 2,
		digitsOptional: false,
		rightAlign: true,
		//unmaskAsNumber: true,
		removeMaskOnSubmit: true
	});

	$('input[name=customFile]').on('change', function () {
		var val = $(this).val();
		$(this).closest('div.custom-file').find('.nome-arquivo').remove();
		if (val != "") {
			$(this).closest('div.custom-file').append('<div class="nome-arquivo">' + val + '</div>');
		}
	});

	$('input.calc-preco').on('keyup', function (e) {

		var tr = $(this).closest('div.card-body');
		var Quantidade = tr.find('input.calc-quantidade').val();
		var Preco = $(this).val();

		Quantidade = (Quantidade == "") ? "0" : Quantidade.replace(".", "").replace(",", ".");
		Preco = (Preco == "") ? "0" : Preco.replace(".", "").replace(",", ".");

		Preco = parseFloat(Preco);
		Quantidade = parseFloat(Quantidade);

		var Resultado = 0;
		Resultado = (Preco * Quantidade).toFixed(2).toString().replace(".", ",");

		tr.find('input.calc-total').val(Resultado);
	});
});

function CheckFornecedorCadastrado() {

	$('#preloader').removeClass('hide');
	$('#preloader div#status').html('Aguarde...');

	var Id = $('input.solicitacao-servico').first().val();

	$.get(
		'/Compra/SolicitacaoServicoCotacao/CheckFornecedorCadastrado',
		{ Id: Id },
		function (d) {
			
			$('#preloader').addClass('hide');

			if (d.ok) {

				var elfornecedor = $('input.fornecedor');
				var elaprovar = $('input.aprovar');
				var list = [];
				for (var i = 0; i < elfornecedor.length; i++) {
					if ($(elaprovar[i]).val() == 'true') {
						list.push($(elfornecedor[i]).val())
                    }
				}

				var msg = "";
				for (var i = 0; i < d.result.length; i++) {
					for (var j = 0; j < list.length; j++) {
						if (list[i] == d.result[i].id) {
							msg += "Fornecedor: " + d.result[i] + ' não cadastrado no protheus';
                        }
					}
					
                }

				if (msg != "") {
					Swal.fire({
						type: "error",
						title: "",
						text: msg,
					});
				} else {

					$('#preloader').removeClass('hide');
					$('#preloader div#status').html('Aguarde...');
					$("form[name=FormCad]").submit();	
                }
				

			} else {
				
				Swal.fire({
					type: "error",
					title: "",
					text: "Erro ao verificar fornecedor cadastrado.",
				});
			}
			
		}
	);


}