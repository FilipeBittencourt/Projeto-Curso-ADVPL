var table;

function Recusar(Id) {

	$('#modal-observacao-evento-antecipacao').modal('hide');

	Swal.fire(
		{
			text: "Deseja recusar a antecipação?",
			type: "warning",
			showCancelButton: true,
			confirmButtonText: "Sim",
			cancelButtonText: "Não"
		}).then(function (result) {
			if (result.value) {

				var Observacao = $('#modal-observacao-evento-antecipacao textarea[name="Observacao"]').val() || "";
				$('#preloader').removeClass('hide');
				$('#preloader div#status').html('Aguarde...');

				$.get(
					'../Fornecedor/Antecipacao/Recusar',
					{ Id: Id, Observacao: Observacao},
					function (d) {

						$('#preloader').addClass('hide');
						var type = ""
						var text = ""

						if (d.ok) {
							type = "success";
							text = "Recusa realizada com sucesso.";
							table.ajax.reload();
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

function Aprovar(Id) {

	$('#modal-detalhe-antecipacao').modal('hide');
	Swal.fire(
		{
			text: "Deseja aprovar a antecipação?",
			type: "warning",
			showCancelButton: true,
			confirmButtonText: "Sim",
			cancelButtonText: "Não"
		}).then(function (result) {
			if (result.value) {

				$('#preloader').removeClass('hide');
				$('#preloader div#status').html('Aguarde...');

				$.get(
					'../Fornecedor/Antecipacao/Aprovar',
					{ Id: Id },
					function (d) {

						$('#preloader').addClass('hide');

						var type = ""
						var text = ""

						if (d.ok) {
							type = "success";
							text = "Aprovação realizada com sucesso.";
							table.ajax.reload();
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

function Aceitar(Id) {

	
	$('#modal-detalhe-antecipacao').modal('hide');
	Swal.fire(
		{
			text: "Deseja aceitar a antecipação?",
			type: "warning",
			showCancelButton: true,
			confirmButtonText: "Sim",
			cancelButtonText: "Não"
		}).then(function (result) {
			if (result.value) {
				$('#preloader').removeClass('hide');
				$('#preloader div#status').html('Aguarde...');

				$.get(
					'../Fornecedor/Antecipacao/Aceitar',
					{ Id: Id },
					function (d) {
						$('#preloader').addClass('hide');

						var type = ""
						var text = ""

						if (d.ok) {
							type = "success";
							text = "Aceite realizado com sucesso.";
							table.ajax.reload();
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

function Cancelar(Id) {

	$('#modal-detalhe-antecipacao').modal('hide');
	Swal.fire(
		{
			text: "Deseja cancelar a antecipação?",
			type: "warning",
			showCancelButton: true,
			confirmButtonText: "Sim",
			cancelButtonText: "Não"
		}).then(function (result) {
			if (result.value) {

				$('#preloader').removeClass('hide');
				$('#preloader div#status').html('Aguarde...');


				$.get(
					'../Fornecedor/Antecipacao/Cancelar',
					{ Id: Id },
					function (d) {

						$('#preloader').addClass('hide');

						var type = ""
						var text = ""

						if (d.ok) {
							type = "success";
							text = "Cancelamento realizada com sucesso.";
							table.ajax.reload();
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



function CancelarAprovada(Id) {

	Swal.fire(
		{
			text: "Deseja cancelar a antecipação?",
			type: "warning",
			showCancelButton: true,
			confirmButtonText: "Sim",
			cancelButtonText: "Não"
		}).then(function (result) {
			if (result.value) {

				$('#preloader').removeClass('hide');
				$('#preloader div#status').html('Aguarde...');


				$.get(
					'../Fornecedor/Antecipacao/Cancel',
					{ Id: Id },
					function (d) {

						$('#preloader').addClass('hide');

						var type = ""
						var text = ""

						if (d.ok) {
							type = "success";
							text = "Cancelamento realizada com sucesso.";
							table.ajax.reload();
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


function LoadTitulosAntecipacao(Id) {

	$('.soma-total').html("0.00");
	$('.soma-total-antecipacao').html("0.00");
	$('#table-antecipacao-detalhe tbody').html("");
	$('.habilitar-observacao').removeClass('hide');

	$('#preloader').removeClass('hide');
	$('#preloader div#status').html('Aguarde...');

	$.get(
		'../Fornecedor/Antecipacao/ListarTitulos?_=' + new Date().getTime(),
		{ Id: Id },
		function (d) {

			$('#preloader').addClass('hide');

			var html = '';
			var soma = 0;
			var somaAntecipacao = 0;
			for (var i = 0; i < d.result.length; i++) {
				html += '<tr>'
				html += '<td>' + d.result[i].numeroDocumento + '</td>'
				html += '<td>' + d.result[i].parcela + '</td>'
				html += '<td>' + d.result[i].dataVencimento + '</td>'
				html += '<td class="text-right">' + d.result[i].valor.toFixed(2) + '</td>'
				html += '<td class="text-right">' + d.result[i].valorAntecipacao.toFixed(2) + '</td>'
				html += '</tr>'
				soma += d.result[i].valor;
				somaAntecipacao += d.result[i].valorAntecipacao;
			}

			if (d.mensagem != "") {
				$('.info-alteracao').closest("div.alert").removeClass("hide");
				$('.info-alteracao').html(d.mensagem);
			}
			
			$('.soma-total').html(soma.toFixed(2));
			$('.soma-total-antecipacao').html(somaAntecipacao.toFixed(2));

			$('#table-antecipacao-detalhe tbody').html(html);

			$('input[name="AntecipacaoId"]').val(Id);

			$('.btn-aceitar').addClass('hide');
			$('.btn-recusar').addClass('hide');
			$('.btn-aprovar').addClass('hide');
			$('.btn-cancelar').addClass('hide');
			$('.btn-alterar').addClass('hide');

			if (d.status) {

				if (d.origem == 0) {

					if (d.evento == 0) {
						$('.btn-aceitar').removeClass('hide');
						$('.btn-recusar').removeClass('hide');
					}

					//aprovado pelo fornecedor
					if (d.evento == 10) {
						$('.btn-cancelar').removeClass('hide');
						$('.btn-aprovar').removeClass('hide');
					}

					//recusado pelo fornecedor
					if (d.evento == 11) {
						$('.btn-cancelar').removeClass('hide');
						$('.btn-alterar').removeClass('hide');
					}

					//alterado pelo cliente
					if (d.evento == 12) {
						$('.btn-aceitar').removeClass('hide');
						$('.btn-recusar').removeClass('hide');
					}


				} else {
					if (d.evento == 0) {
						$('.btn-cancelar').removeClass('hide');
						$('.btn-aprovar').removeClass('hide');
						$('.btn-alterar').removeClass('hide');
					}

					//aprovado pelo fornecedor
					if (d.evento == 10) {
						$('.btn-cancelar').removeClass('hide');
						$('.btn-aprovar').removeClass('hide');
					}

					//recusado pelo fornecedor
					if (d.evento == 11) {
						$('.btn-cancelar').removeClass('hide');
						$('.btn-alterar').removeClass('hide');
					//	$('.btn-aprovar').removeClass('hide');
					}

					//alterado pelo cliente
					if (d.evento == 12) {
						$('.btn-aceitar').removeClass('hide');
						$('.btn-recusar').removeClass('hide');
					}
				}

			}
			
			$('#modal-detalhe-antecipacao').modal('show');
		}
	);
}


function GetIdAntecipacao() {
	var el = $('input[name=checkItem]');
	var cont = 0;
	var Id = 0;
	for (var i = 0; i < el.length; i++) {

		if ($(el[i]).prop('checked')) {
			cont++;
			Id = $(el[i]).closest('div.check-item').find('input[name="Id"]').val();
		}

	}

	if (cont == 1) {
		return Id;
	}

	Swal.fire({
		type: 'error',
		title: "",
		text: "Selecione uma antecipação.",
	});

	return "";
}

function Atualizar() {
	//var Id = GetIdAntecipacao();

	var Id = $('input[name="AntecipacaoId"]').val();
	if (Id != "") {
		
		$('#preloader').removeClass('hide');
		$('#preloader div#status').html('Aguarde...');

		var NovaTaxa = $('#modal-atualizar-antecipacao input[name="NovaTaxa"]').val() || "0";
		var DataRecebimento = $('#modal-atualizar-antecipacao input[name="DataRecebimento"]').val() || "";
		var Observacao = $('#modal-atualizar-antecipacao textarea[name="Observacao"]').val() || "";
		var AtualizarCadastro = $('#modal-atualizar-antecipacao input[name="AtualizarCadastro"]').val() || "";


		NovaTaxa = NovaTaxa.replace(".", ",");

		$.post(
			'../Fornecedor/Antecipacao/AtualizarAntecipacao',
			{ Id: Id, NovaTaxa: NovaTaxa, Observacao: Observacao, AtualizarCadastro: AtualizarCadastro, DataRecebimento: DataRecebimento  },
			function (d) {

				$('#preloader').addClass('hide');

				table.ajax.reload();
				$('#modal-atualizar-antecipacao').modal('hide');

				if (d.ok != true) {
					Swal.fire({
						type: 'error',
						title: "",
						text: d.mensagem,
					});
				}

			}
		);	
	}
}

function GetStatusAntecipacao() {

	var Id = GetIdAntecipacao();
	if (Id != "") {

		$('#modal-atualizar-antecipacao input[name="NovaTaxa"]').val(0)
		$('#modal-atualizar-antecipacao textarea[name="Observacao"]').val("") 
		$('#modal-atualizar-antecipacao input[name="AtualizarCadastro"]').prop('checked', false);

		$('#preloader').removeClass('hide');
		$('#preloader div#status').html('Aguarde...');

		$.get(
			'../Fornecedor/Antecipacao/GetStatusAntecipacao',
			{ Id: Id },
			function (d) {

				$('#preloader').addClass('hide');

				if (d.status == 1) {
					$('#modal-atualizar-antecipacao').modal('show');
				} else {
					Swal.fire({
						type: 'error',
						title: "",
						text: d.mensagem,
					});
				}

			}
		);	

	}
}


$(function () {

	$("input[name=NovaTaxa]").on("change", function () {
		$(this).val(parseFloat($(this).val()).toFixed(2));
	});

	$('#dt-registro').on('click', 'a.btn-antecipacao', function () {
		var Id = $(this).attr('id')//$(this).closest('tr').find('input[name="Id"]').val();
		LoadTitulosAntecipacao(Id);
	});


	$('#dt-registro').on('click', 'a.btn-cancelar-aprovada', function () {
		var Id = $(this).attr('id')//$(this).closest('tr').find('input[name="Id"]').val();
		CancelarAprovada(Id);
	});



	$('.btn-aceitar').on('click', function () {
		var Id = $('input[name="AntecipacaoId"]').val();
		Aceitar(Id);
	});

	$('.btn-aprovar').on('click', function () {
		var Id = $('input[name="AntecipacaoId"]').val();
		Aprovar(Id);
	});

	$('.btn-cancelar').on('click', function () {
		var Id = $('input[name="AntecipacaoId"]').val();
		Cancelar(Id);
	});

	$('.btn-alterar').on('click', function () {

		$('#modal-atualizar-antecipacao input[name="NovaTaxa"]').val('');
		$('#modal-atualizar-antecipacao input[name="DataRecebimento"]').val('');
		$('#modal-atualizar-antecipacao textarea[name="Observacao"]').val();
		$('#modal-atualizar-antecipacao input[name="AtualizarCadastro"]').prop('checked', false);

		$('#modal-detalhe-antecipacao').modal('hide');
		$('#modal-atualizar-antecipacao').modal('show');

	});

	$('.btn-atualizar').on('click', function () {
		Atualizar();	
	});

	$('.btn-recusar').on('click', function () {
		$('#modal-detalhe-antecipacao').modal('hide');
		$('#modal-observacao-evento-antecipacao textarea[name="Observacao"]').val('');
		$('#modal-observacao-evento-antecipacao').modal('show');
	});

	$('.btn-recusa-evento').on('click', function () {
		var Id = $('input[name="AntecipacaoId"]').val();
		Recusar(Id);		
	});

	order = [[5, "desc"], [9, "asc"]]
	columnsDataTable = [
		{
			"render": function (data, type, full, meta) {
				var html = '<div class="custom-control custom-checkbox mr-3 order-1 check-item">'
				html += '<input type="hidden" name="Id" value="' + full.id + '">'
				html += '<input type="checkbox" name="checkItem" class="custom-control-input" id="checkItem' + loopCheckItem + '">'
				html += '<label class="custom-control-label" for="checkItem' + loopCheckItem + '"></label>'
				html += '</div>'
				loopCheckItem++;
				return html;
			}
		},
		{
			"data": "nomeUnidade", "name": "NomeUnidade"
		},
		{
			"data": "fornecedor", "name": "Fornecedor"
		},
		{
			"data": "tipo", "name": "Tipo"
		},
		{
			"data": "dataEmissao", "name": "DataEmissao"
		},
		{
			"data": "dataRecebimento", "name": "DataRecebimento"
		},
		{
			"data": "taxa", "name": "Taxa"
		},
		{
			"data": "valor", "name": "Valor"
		},
		{
			"data": "origem", "name": "Origem"
		},
		{
			"data": "status", "name": "Status",
			"render": function (data, type, full, meta) {

				var classSpan = "badge-warning";
				if (full.status == 'Aprovada') {
					classSpan = "badge-success";
				} else if (full.status == 'Cancelada') {
					classSpan = "badge-danger";
				}

				var html = '<h4><span class="badge ' + classSpan + '">' + full.status + '</span></h4>'
				return html;
			}
		},
		{
			"render": function (data, type, full, meta) {

				var html = ""

				html += '<div class="d-flex demo">'

				html += '<a title="Antecipação" href="javascript:void(0)" class="btn btn-icon btn-inline-block mr-1 btn-antecipacao" id="' + full.id + '" >'
				html += '<i class="fal fa-search color-fusion-300"></i>'
				html += '</a>'

				html += '<a title="Excel" href="../fornecedor/antecipacao/exportarexcel/' + full.id + '" target="_blank" class="btn btn-icon btn-inline-block mr-1" >'
				html += '<i class="fal fa-file-excel color-fusion-300"></i>'
				html += '</a>'

				if (TipoUsuario != 1)
				{
					html += '<a title="Histórico Antecipação" href="../fornecedor/antecipacao/details/' + full.id + '" target="_blank" class="btn btn-icon btn-inline-block mr-1" >'
					html += '<i class="fal fa-file-alt color-fusion-300"></i>'
					html += '</a>'

					//if (full.status == 'Aprovada') {
						html += '<a title="Cancelar Antecipação" href="javascript:void(0)" class="btn btn-icon btn-inline-block mr-1 btn-cancelar-aprovada" id="' + full.id + '" >'
						html += '<i class="fal fa-ban color-fusion-300"></i>'
						html += '</a>'
					//}
				}
				
				html += '</div>'

				return html;
			}
		}
	]
	
	if (typeof TipoUsuario !== 'undefined' && TipoUsuario == 1) {
		columnsDataTable.splice(2, 1)//remove coluna fornecedor
		columnsDataTable.splice(7, 1)//remove coluna Origem
		order = [[4, "desc"]]
	}

	if (FiltroStatus != "") {
		$('input[name=FieldSearch]').val('Status=' + FiltroStatus)
	}

	var loopCheckItem = 0;
	table = $('#dt-registro').DataTable(
		{
			'columnDefs': [{ "orderable": false, "targets": 0 }],
			"order": order,
			orderCellsTop: true,
			fixedHeader: true,
			dom: "<'row mb-3'<'col-sm-12 col-md-6 d-flex align-items-center justify-content-start'B><'col-sm-12 col-md-6 d-flex align-items-center justify-content-end'l>>" +
				"<'row'<'col-sm-12'tr>>" +
				"<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7'p>>",
			buttons: [
				
			],
			"responsive": true,
			"processing": true,
			"serverSide": true,
			"ajax": {
				"url": "../Fornecedor/Antecipacao/DataTable",
				"type": "POST",
				"datatype": "json",
				"data": {
					FieldSearch: function () {
						return $('input[name=FieldSearch]').val()
					},
				},
			},

			"columns": columnsDataTable,
			"lengthMenu": [[10, 20, 30, -1], [10, 20, 30, "All"]],
			"aaSorting": [],
			"oLanguage": {
				"oPaginate": {
					"sNext": ">",
					"sFirst": "<<",
					"sLast": ">>",
					"sPrevious": "<"
				},
				"sLengthMenu": "Mostrar:  _MENU_",
				"sZeroRecords": "Não há registros correspondentes foram encontrados",
				"sInfo": "Mostrando _START_ a _END_ de _TOTAL_ no total",
				"sInfoEmpty": "Mostrando 0 a 0 de 0 no total",
				"sInfoFiltered": "(filtrado das _MAX_ entradas totais)",
				"sSearch": "Filtrar: ",
				"sEmptyTable": "Não há dados disponíveis na tabela",
				"sLoadingRecords": "Carregando...",
				"sProcessing": "Processando..."
			},
		});

	
	var CamposFiltro = ['','NomeUnidade', 'Fornecedor', 'Tipo', 'DtEmissao', 'DtRecebimento', 'Taxa', 'Valor', 'Origem', 'Status',''];

	if (typeof TipoUsuario !== 'undefined' && TipoUsuario == 1) {
		CamposFiltro = ['', 'NomeUnidade', 'Tipo','DtEmissao', 'DtRecebimento', 'Taxa', 'Valor', 'Status', ''];	
	}

	$('#dt-registro thead tr').clone(false).appendTo('#dt-registro thead');
	$('#dt-registro thead tr:eq(1) th').each(function (i) {
		$(this).removeClass('sorting');
		if (i != 0 && i != CamposFiltro.length-1) {

			var value = "";
			var classe = "";

			if (CamposFiltro[i] == 'Status') {
				if (FiltroStatus != "") {
					value = FiltroStatus;
					classe = 'filter-ativo';
				}
			}

			$(this).html('<div class="form-check-inline" style="width: 100%;"><div class="" style="width: 100%;"><input type="text" name="' + CamposFiltro[i] + '" value="' + value+'" class="form-control form-control-sm search" placeholder=""></div><div class="" ><div class="columnFilter filter-search" ><i class="fal fa-filter mr-1 '+classe+'"></i></div></div>');

			

			$('input', this).on('keyup', function (e) {

				if (e.keyCode == 13) {
					FuncSearch(this, table);
				}

			});

		} else {

			var html = ''

			$(this).html(html);
		}
	});


	$('.filter-search').on('click', function () {
		FuncSearch(this, table);
	});

	$('.filter-close').on('click', function () {
		$(this).closest('th').find('input').val('');
		FuncSearch(table);
	});

	

});