var table;

$(function () {

	var loopCheckItem = 0;
	table = $('#dt-registro').DataTable(
		{
			'columnDefs': [{ "orderable": false, "targets": 0 }],
			"order": [[0, "desc"]],
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
				"url": "../SAC/Atendimento/DataTable",
				"type": "POST",
				"datatype": "json",
				"data": {
					FieldSearch: function () {
						return $('input[name=FieldSearch]').val()
					},
				},
			},

			"columns": [
				{
					"data": "id", "name": "ID"
				},
				{
					"data": "numero", "name": "Numero"
				},
				{
					"data": "nomeFornecedor", "name": "NomeFornecedor"
				},
				{
					"data": "nomeReclamante", "name": "nomeReclamante"
				},
				{
					"data": "nomeProduto", "name": "NomeProduto"
				},
				{
					"data": "quantidade", "name": "Quantidade"
				},
				{
					"data": "status", "name": "Status",
					"render": function (data, type, full, meta) {

						var classSpan = "badge-primary";
						if (full.status == 'Finalizado') {
							classSpan = "badge-success";
						} else if (full.status == 'Reprovada') {
							classSpan = "badge-danger";
						} else if (full.status == 'Serviço Realizado') {
							classSpan = "badge-info";
                        }
						//

						var html = '<h4><span class="badge ' + classSpan + '">' + full.status + '</span></h4>'
						return html;
					}
				},
				{
					"render": function (data, type, full, meta) {

						var html = ""

						html += '<div class="d-flex demo">'
						html += '<a title="Anexo Serviço" href="javascript:void(0)" id="'+full.id+'" class="btn btn-icon btn-inline-block mr-1 btn-anexo-atendimento" >'
						html += '<i class="fal fa-upload  color-fusion-300"></i>'
						html += '</a>'
						html += '<a title="Concluir Atendimento" href="javascript:void(0)" atendimentoid="' + full.id + '" atendimentoevento="A" class="btn btn-icon btn-inline-block mr-1 btn-concluir-atendimento" >'
						html += '<i class="fal fa-check color-fusion-300"></i>'
						html += '</a>'

						html += '<a title="Atendimento" href="../SAC/Atendimento/details/' + full.id + '" target="_blank" class="btn btn-icon btn-inline-block mr-1" >'
						html += '<i class="fal fa-search color-fusion-300"></i>'
						html += '</a>'

						html += '<a title="Termo" href="../SAC/Atendimento/GetTermo/' + full.id + '" target="_blank" class="btn btn-icon btn-inline-block mr-1" >'
						html += '<i class="fal fa-paperclip color-fusion-300"></i>'
						html += '</a>'

						html += '</div>'

						return html;
					}
				}				
			],
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

	var CamposFiltro = ['ID', 'Numero', 'NomeFornecedor', 'NomeReclamante',  'NomeProduto', 'Quantidade', 'Status', ''];
	$('#dt-registro thead tr').clone(false).appendTo('#dt-registro thead');

	$('#dt-registro thead tr:eq(1) th').each(function (i) {
		$(this).removeClass('sorting');

		if (CamposFiltro[i] != "") {
			var title = $(this).text();

			$(this).html('<div class="form-check-inline" style="width: 100%;"><div class="" style="width: 100%;"><input type="text" name="' + CamposFiltro[i] + '" class="form-control form-control-sm search" placeholder=""></div><div class="" ><div class="columnFilter filter-search" ><i class="fal fa-filter mr-1"></i></div></div>');

			$('input', this).on('keyup', function (e) {

				if (e.keyCode == 13) {
					FuncSearch(this, table);
				}

			});
		} else {
			$(this).html('');
        }	

	});


	$('.filter-search').on('click', function () {
		FuncSearch(this, table);
	});

	$('.filter-close').on('click', function () {
		$(this).closest('th').find('input').val('');
		FuncSearch(table);
	});


	$('#dt-registro').on('click', 'a.btn-anexo-atendimento', function () {
		ShowModalAnexoAtendimento(this)
	});


	$('.btn-novo-atendimento').on('click',
		function () {
			AdicionarAnexo('tabela-novo-anexo-atendimento');
		}
	);

	$('.btn-salvar-documento').on('click',
		function () {
			SalvarAnexoAtendimento();
		}
	);

	$("#tabela-novo-anexo-atendimento").on("click", ".btn-delete-anexo",
		function () {
			var tr = $(this).closest('tr');
			tr.fadeOut(100, function () {
				tr.remove();
			});
		}
	);

	$("#tabela-novo-anexo-atendimento").on("click", ".btn-delete-anexo-list",
		function () {
			RemoveAnexoAtendimento(this)			
		}
	);

	$('#tabela-novo-anexo-atendimento').on('change', 'input[name=Arquivo]', function () {
		var val = $(this).val();

		$(this).closest('div.custom-file').find('.nome-arquivo').remove();
		if (val != "") {
			$(this).closest('div.custom-file').append('<div class="nome-arquivo">'+val+'</div>');
        }
	});

	$('#dt-registro').on('click', 'a.btn-concluir-atendimento', function () {
		Concluir(this)
	});

});


function LoadAnexoAtendimento(Id) {

	$('#preloader').removeClass('hide');
	$('#preloader div#status').html('Aguarde...');
	$('#tabela-novo-anexo-atendimento tbody').html('');

	$.get(
		'../SAC/Atendimento/GetListAnexoAtendimento?_=' + new Date().getTime(),
		{ Id: Id },
		function (d) {

			$('#preloader').addClass('hide');

			html = "";
			if (d.ok) {
				for (var i = 0; i < d.result.length; i++) {
					html += '<tr>'
					html += '<td>' + d.result[i].descricao + '</td>'
					html += '<td><a target="_blank" href="../SAC/Atendimento/GetAnexoAtendimento/' + d.result[i].id + '" class="" >' + d.result[i].nome + '</a></td>'
					html += '<td class="text-right"><a href="javascript:void(0)" atendimentomedicaoid="'+ d.result[i].id +'" class="btn btn-icon fs-xl waves-effect waves-themed btn-delete-anexo-list" ><i class="fal fa-trash-alt color-fusion-300"></i></a></td>'
					html += '</tr>'
				}
			}

			$('#tabela-novo-anexo-atendimento tbody').html(html);

			$('#modal-anexo-atendimento').modal('show');
		}
	);
}


function ShowModalAnexoAtendimento(el) {
	var Id = $(el).closest('a').attr('id');
	$("form[name=cadAnexoAtendimento] input[name='AtendimentoID']").val(Id);
	LoadAnexoAtendimento(Id);
}


function RemoveAnexoAtendimento(el) {

	var Id = $(el).closest('a').attr('atendimentomedicaoid');
	$('#modal-anexo-atendimento').modal('hide');
	Swal.fire(
	{
		text: "Deseja remover o anexo?",
		type: "warning",
		showCancelButton: true,
		confirmButtonText: "Sim",
		cancelButtonText: "Não"
	}).then(function (result) {
		if (result.value) {

			$('#preloader').removeClass('hide');
			$('#preloader div#status').html('Aguarde...');

			$.get(
				'../SAC/Atendimento/RemoverAnexo',
				{ Id: Id },
				function (d) {

					$('#preloader').addClass('hide');

					var type = ""
					var text = ""

					if (d.ok) {
						type = "success";
						text = "Anexo removido com sucesso.";

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

function SalvarAnexoAtendimento() {
	
	$('#modal-anexo-atendimento').modal('hide');
	Swal.fire(
		{
			text: "Deseja salvar os arquivos informados?",
			type: "warning",
			showCancelButton: true,
			confirmButtonText: "Sim",
			cancelButtonText: "Não"
		}).then(function (result) {
			if (result.value) {

				$('#preloader').removeClass('hide');
				$('#preloader div#status').html('Aguarde...');

				var formdata = new FormData($('#cadAnexoAtendimento')[0]);
				
				$.ajax({
					type: 'POST',
					url: '../SAC/Atendimento/SalvarAnexo',
					data: formdata,
					processData: false,
					contentType: false
				}).done(function (d) {

					$('#preloader').addClass('hide');

					var type = ""
					var text = ""

					if (d.ok) {
						type = "success";
						text = "Arquivos salvo com sucesso.";
					} else {
						type = "error"
						text = d.mensagem
					}

					Swal.fire({
						type: type,
						title: "",
						text: text,
					});

				});

			}
		});
}


var loopAnexo = 0;
function AdicionarAnexo(tabela) {

	
	var tipo = ['text', 'file', 'html'];
	var nome = ['Descricao', 'Arquivo', ''];
	var id = ['Descricao' + loopAnexo, 'Arquivo' + loopAnexo, ''];
	var valor = ["", "", '<a href="javascript:void(0)" class="btn btn-icon fs-xl waves-effect waves-themed btn-delete-anexo" ><i class="fal fa-trash-alt color-fusion-300"></i></a>'];
	var estilo = ["form-control select2-select", "custom-file-input", ""];
	var estiloCell = ["", "", "center"];
	var colspanCell = ["", "", ""];
	var outros = ["", "style='width: 60%'", ""];
	addRow(tabela, tipo, nome, id, valor, estilo, outros, estiloCell, colspanCell, colspanCell);
	loopAnexo++;
}



function Concluir(el) {

	var Id = $(el).closest('a').attr('atendimentoid');

	Swal.fire(
		{
			text: 'Deseja concluir Atendimento?',
			type: "warning",
			showCancelButton: true,
			confirmButtonText: "Sim",
			cancelButtonText: "Não"
		}).then(function (result) {
			if (result.value) {

				$('#preloader').removeClass('hide');
				$('#preloader div#status').html('Aguarde...');

				$.post(
					'../SAC/Atendimento/SalvarStatus',
					{ Id: Id },
					function (d) {

						$('#preloader').addClass('hide');

						var type = ""
						var text = ""

						if (d.ok) {
							type = "success";
							text = "Atendimento concluida com sucesso.";

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


