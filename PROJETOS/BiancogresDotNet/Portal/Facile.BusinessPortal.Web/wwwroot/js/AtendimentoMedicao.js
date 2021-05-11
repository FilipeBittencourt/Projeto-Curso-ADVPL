var table;

$(function () {

	var loopCheckItem = 0;
	table = $('#dt-registro').DataTable(
		{
			'columnDefs': [{ "orderable": false, "targets": 0 }],
			"order": [[1, "desc"]],
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
				"url": "../SAC/AtendimentoMedicao/DataTable",
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

						var html = '<h4><span class="badge ' + classSpan + '">' + full.status + '</span></h4>'
						return html;
					}
				},
				{
					"render": function (data, type, full, meta) {

						var html = ""

						html += '<div class="d-flex demo">'
						html += '<a title="Anexos" href="javascript:void(0)" atendimentoid="' + full.id +'" class="btn btn-icon btn-inline-block mr-1 btn-anexo" >'
						html += '<i class="fal fa-search color-fusion-300"></i>'
						html += '</a>'
						html += '<a title="Aprovar" href="javascript:void(0)" atendimentoid="'+full.id+'" atendimentoevento="A" class="btn btn-icon btn-inline-block mr-1 btn-aprovar-reprovar" >'
						html += '<i class="fal fa-check color-fusion-300"></i>'
						html += '</a>'
						html += '<a title="Reprovar" href="javascript:void(0)" atendimentoid="' + full.id +'" atendimentoevento="R" class="btn btn-icon btn-inline-block mr-1 btn-aprovar-reprovar" >'
						html += '<i class="fal fa-ban color-fusion-300"></i>'
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

	var CamposFiltro = ['ID', 'Numero', 'NomeFornecedor', 'NomeReclamante', 'NomeProduto', 'Quantidade', 'Status', ''];
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

	$('#dt-registro').on('click', 'a.btn-aprovar-reprovar', function () {
		ShowModalAprovarReprovar(this)
	});

	$('.btn-salvar-aprovar-reprovar').on('click',
		function () {
			AprovarReprovar();
		}
	);

	$('#dt-registro').on('click', 'a.btn-anexo', function () {
		LoadAnexoAtendimento(this)
	});
});


function ShowModalAprovarReprovar(el) {
	var Id = $(el).closest('a').attr('atendimentoid');
	var AtendimentoEvento = $(el).closest('a').attr('atendimentoevento');
	$("form[name=cadAtendimentoAprovarReprovar] input[name='AtendimentoID']").val(Id);
	$("form[name=cadAtendimentoAprovarReprovar] input[name='AtendimentoEvento']").val(AtendimentoEvento);
	$("form[name=cadAtendimentoAprovarReprovar] textarea[name='Observacao']").val('');
	$('#modal-atendimento-aprovar-reprovada').modal('show');
}


function AprovarReprovar() {

	var text = "";
	var Status = 0;

	var Id = $("form[name=cadAtendimentoAprovarReprovar] input[name='AtendimentoID']").val();
	var Evento = $("form[name=cadAtendimentoAprovarReprovar] input[name='AtendimentoEvento']").val();
	var Observacao = $("form[name=cadAtendimentoAprovarReprovar] textarea[name='Observacao']").val();

	if (Evento == 'A') {
		text = "Deseja aprovar Atendimento?"
		Status = 1;
	} else if (Evento == 'R') {
		text = "Deseja reprovar Atendimento?"
		Status = 2;
    }

	$('#modal-atendimento-aprovar-reprovada').modal('hide');

	Swal.fire(
		{
			text: text,
			type: "warning",
			showCancelButton: true,
			confirmButtonText: "Sim",
			cancelButtonText: "Não"
		}).then(function (result) {
			if (result.value) {

				$('#preloader').removeClass('hide');
				$('#preloader div#status').html('Aguarde...');

				$.post(
					'../SAC/AtendimentoMedicao/SalvarStatus',
					{ Id: Id, Status: Status, Observacao: Observacao},
					function (d) {

						$('#preloader').addClass('hide');

						var type = ""
						var text = ""

						if (d.ok) {
							type = "success";
							text = "Informação gravada com sucesso.";

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


function LoadAnexoAtendimento(el) {

	var Id = $(el).closest('a').attr('atendimentoid');
	$('#preloader').removeClass('hide');
	$('#preloader div#status').html('Aguarde...');
	$('#tabela-anexo-atendimento tbody').html('');

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
					html += '</tr>'
				}
			}

			$('#tabela-anexo-atendimento tbody').html(html);

			$('#modal-atendimento-anexo').modal('show');
		}
	);
}

