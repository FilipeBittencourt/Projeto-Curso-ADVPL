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
				"url": "/Compra/SolicitacaoServico/DataTableFornecedor",
				"type": "POST",
				"datatype": "json",
				"data": {
					FieldSearch: function () {
						return $('input[name=FieldSearch]').val()
					},
				},
			},
			//	var CamposFiltro = ['ID', 'Numero', 'Prioridade', 'DataNecessidade', 'TipoServico', 'TipoVisita', 'Status',''];
			"columns": [
				{
					"data": "numero", "name": "Numero"
				},
				{
					"data": "dataEmissao", "name": "dataEmissao"
				},
				{
					"data": "nomeSolicitante", "name": "NomeSolicitante"
				},
				{
					"data": "nomeSolicitanteReal", "name": "NomeSolicitanteReal"
				},
				{
					"data": "contatoSolicitante", "name": "contatoSolicitante"
				},
				{
					"data": "dataNecessidade", "name": "dataNecessidade"
				},
				{
					"data": "descricao", "name": "descricao"
				},
				{
					"data": "tipoServico", "name": "tipoServico"
				},
				{
					"data": "tipoVisita", "name": "tipoVisita"
				},
				{
					"data": "dataVisita", "name": "dataVisita"
				},
				{
					"data": "status", "name": "Status",
					"render": function (data, type, full, meta) {

						var classSpan = "badge-primary";
						if (full.status == 'Finalizado') {
							classSpan = "badge-success";
						} 

						var html = '<h4><span class="badge ' + classSpan + '">' + full.status + '</span></h4>'
						return html;
					}
				},
				{
					"render": function (data, type, full, meta) {

						var html = ""
						
						html += '<div class="dropdown">																															';
						html += '	<a href="#" class="btn btn-default btn-icon waves-effect waves-themed" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">   ';
						html += '		<i class="ni ni-menu"></i>                                                                                                              ';
						html += '	</a>                                                                                                                                        ';
						html += '	<div class="dropdown-menu" x-placement="top-start" style="position: absolute; will-change: top, left; top: -201px; left: 0px;">             ';
						html += '		<a class="dropdown-item" href="../Compra/SolicitacaoServico/details/' + full.id + '" >Detalhes</a>																		';

						if (full.vencedor == true) {
							if (full.tipoServico == 'Contrato') {
								html += '		<a class="dropdown-item" href="../Compra/SolicitacaoServicoMedicao/CreateMedicao/' + full.id + '" >Medição</a> 																		';
							} else if (full.tipoServico == 'Pedido') {
								html += '		<a class="dropdown-item" href="../Compra/SolicitacaoServicoMedicaoUnica/CreateMedicao/' + full.id + '" >Anexo Nota Fiscal</a>																		';
							}
						}

						html += '		<a class="dropdown-item" href="../Compra/SolicitacaoServicoCotacao/Edit/' + full.id + '" >Cotação</a>                                                                   ';
						html += '		<a class="dropdown-item" href="../Compra/SolicitacaoServicoFornecedorVisitante/CreateVisitante/' + full.id + '">Visitante</a>                           ';
						html += '		<a class="dropdown-item" href="../Compra/SolicitacaoServico/GetEscopo/' + full.id + '" >Escopo</a>                                                                   ';
						html += '	</div>                                                                                                                                      ';
						html += '</div>            ';

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

	var CamposFiltro = ['Numero', 'DataEmissao', 'NomeSolicitante','NomeSolicitanteReal' ,'ContatoSolicitante', 'DataNecessidade', "Descricao", 'TipoServico', 'TipoVisita', 'DataVisita',  'Status',''];
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

	
});


