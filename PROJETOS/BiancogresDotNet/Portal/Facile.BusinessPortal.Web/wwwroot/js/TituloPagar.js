var table;

$(function () {

	var loopCheckItem = 0;
	table = $('#dt-registro').DataTable(
		{
			'columnDefs': [{ "orderable": false, "targets": 0 }],
			"order": [[6, "desc"], [7, "asc"]],
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
				"url": "../Fornecedor/TituloPagar/DataTable",
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
					"render": function (data, type, full, meta) {
						var html = '<div class="custom-control custom-checkbox mr-3 order-1">'
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
					"data": "nomeFornecedor", "name": "NomeFornecedor"
				},
				{
					"data": "numero", "name": "Numero"
				},
				{
					"data": "serie", "name": "Serie"
				},
				{
					"data": "dataEmissao", "name": "DataEmissao"
				},
				{
					"data": "dataVencimento", "name": "DataVencimento"
				},
				{
					"data": "status", "name": "Status",
					"render": function (data, type, full, meta) {

						var classSpan = "badge-success";
						if (full.status == 'Vencido') {
							classSpan = "badge-danger";
						}

						var html = '<h4><span class="badge ' + classSpan + '">' + full.status + '</span></h4>'
						return html;
					}
				},
				{
					"data": "valorTitulo", "name": "ValorTitulo"
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

	var CamposFiltro = ['NomeUnidade', 'NomeFornecedor', 'Numero', 'Serie',/* 'NumeroDocumento',*/ 'DtEmissao', 'DtVencimento', 'Status', 'ValorTitulo'/*, 'ValorAntecipado'*/];
	$('#dt-registro thead tr').clone(false).appendTo('#dt-registro thead');

	$('#dt-registro thead tr:eq(1) th').each(function (i) {
		if (i > 0) {
			$(this).removeClass('sorting');


			var title = $(this).text();

			$(this).html('<div class="form-check-inline" style="width: 100%;"><div class="" style="width: 100%;"><input type="text" name="' + CamposFiltro[i-1] + '" class="form-control form-control-sm search" placeholder=""></div><div class="" ><div class="columnFilter filter-search" ><i class="fal fa-filter mr-1"></i></div></div>');


			$('input', this).on('keyup', function (e) {

				if (e.keyCode == 13) {
					FuncSearch(this, table);
				}

			});

			
		} else {

			var html = '<div class="custom-control custom-checkbox mr-3 pb-2 order-1 checkAll">'
			html += '<input type="checkbox" class="custom-control-input" id="checkAll">'
			html += '<label class="custom-control-label" for="checkAll"></label>'
			html += '</div>'

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
