var table;


var loopCheckItem = 0;
$(document).ready(function () {

	var table = $('#dt-registro').DataTable(
		{
			'columnDefs': [{ "orderable": false, "targets": -1 }],
			"order": [[1, "asc"]],
			orderCellsTop: true,
			fixedHeader: true,
			dom: "<'row mb-3'<'col-sm-12 col-md-6 d-flex align-items-center justify-content-start'B><'col-sm-12 col-md-6 d-flex align-items-center justify-content-end'l>>" +
				"<'row'<'col-sm-12'tr>>" +
				"<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7'p>>",
			"responsive": true,
			"processing": true,
			"serverSide": true,
			buttons: [
				{
					text: '<i class="fal fa-plus mr-1"></i> Novo',
					className: 'btn btn-outline-primary waves-effect waves-themed',
					action: function (e, dt, node, config) {
						window.location.href = UrlBase+'/create'
					}
				}
			],
			"ajax": {
				"url": UrlBase + "/DataTable",
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
					"data": "nome", "name": "Nome"
				},
				{
					"render": function (data, type, full, meta) {

						var html = ''

						html += '<a href="' + UrlBase + '/edit/' + full.id +'" class="btn btn-icon fs-xl waves-effect waves-themed" >'
						html += '<i class="fal fa-edit color-fusion-300"></i>'
						html += '</a>'

						html += '<a href="' + UrlBase+'/delete/'+full.id+'" class="btn btn-icon fs-xl waves-effect waves-themed" >'
						html +=			'<i class="fal fa-trash-alt color-fusion-300"></i>'
						html += '</a>'

						

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

	
		var CamposFiltro = ['Nome'];
		$('#dt-registro thead tr').clone(false).appendTo('#dt-registro thead');
		$('#dt-registro thead tr:eq(1) th').each(function (i) {

			$(this).removeClass('sorting');
			if (i < CamposFiltro.length) {

				var title = $(this).text();
				$(this).html('<div class="form-check-inline" style="width: 100%;"><div class="" style="width: 100%;"><input type="text" name="' + CamposFiltro[i] + '" class="form-control form-control-sm search" placeholder=""></div><div class="" ><div class="columnFilter filter-search"><i class="fal fa-filter mr-1"></i></div></div>');

				$('input', this).on('keyup change', function (e) {
					if (e.keyCode == 13) {
						FuncSearch(this, table);
					}
				});
			} else {
				$(this).html('');
			}
		});
		
		$('.filter-search').on('click', function() {
			FuncSearch(this, table);
		});
	
});

var loopSolicitante = 0;
function adicionarSolicitante(tabela) {

	var tipo = new Array('select', 'html');
	var nome = new Array('Solicitante',  '');
	var id = new Array('Solicitante' + loopSolicitante,  '');
	var valor = new Array("", '<a href="javascript:void(0)" class="btn btn-icon fs-xl waves-effect waves-themed btn-delete-solicitante" ><i class="fal fa-trash-alt color-fusion-300"></i></a>');
	var estilo = new Array("form-control select2", "");
	var estiloCell = new Array("", "center");
	var colspanCell = new Array( "1", "1");
	var outros = new Array(""," ");
	addRow(tabela, tipo, nome, id, valor, estilo, outros, estiloCell, colspanCell, colspanCell);
	loadSelect2('#Solicitante' + loopSolicitante);
	loopSacado++;
}

function loadSelect2(el) {
	var o = el || ".select2"
	$(o).select2(
		{
			ajax:{
				url: UrlBase + "/GetSolicitante",
				dataType: 'json',
				//delay: 250,
				dropdownParent: $('#FormCad'),
				data: function (params) {
					return {
						q: params.term, // search term
						page: params.page
					};
				},
				processResults: function (data, params) {
					params.page = params.page || 1;
					return {
						results: data.items,
						pagination:
							{
								more: (params.page * 30) < data.total_count
							}
					};
				},
				cache: true
			},
			"language": {
				"searching": function () {
					return "procurando...";
				},
				"inputTooShort": function (args) {
					var remainingChars = args.minimum - args.input.length;

					var message = 'Insira ' + remainingChars + ' ou  mais caracteres';

					return message;
				},
			},
			placeholder: 'Selecione...',
			escapeMarkup: function (markup) {
				return markup;
			}, // let our custom formatter work
			minimumInputLength: 1,
			templateResult: formatRepo,
			templateSelection: formatRepoSelection
		}).change(function (el) {

			var data = $(el.target).select2('data');
			
		});
}

function formatRepo(repo) {
	if (repo.loading) {
		return repo.text;
	}

	var markup = "<div class='select2-result-repository clearfix d-flex'>" +
		"<div class='select2-result-repository__meta'>" +
		"<div class='select2-result-repository__title fs-lg fw-500'>" + repo.nome + "</div>";

	markup += "<div class='select2-result-repository__description fs-xs opacity-80 mb-1'>" + repo.nome + "</div>";

	markup += "<div class='select2-result-repository__statistics d-flex fs-sm'>" +
		"<div class='select2-result-repository__forks mr-2'></div>" +
		"<div class='select2-result-repository__stargazers mr-2'></div>" +
		"<div class='select2-result-repository__watchers mr-2'></div>" +
		"</div>" +
		"</div></div>";

	return markup;
}

function formatRepoSelection(repo) {

	return repo.nome || repo.text;
}


$(document).ready(function () {

		$('.btn-novo-sacado').on('click',
			function () {
				adicionarSacado('tabela-novo-solicitante');
			}
		);

		$("#tabela-novo-sacado").on("click", ".btn-delete-solicitante",
			function () {
				var tr = $(this).closest('tr');
				tr.fadeOut(100, function () {
					tr.remove();
				});
			}
		);


		$('input[name="Habilitado"]').on('click',
			function () {
				$(this).val($(this).prop('checked'));
			}
		);

	loadSelect2();


});
