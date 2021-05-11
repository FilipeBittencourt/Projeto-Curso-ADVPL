var myTable;

function GetElementosChecked() {

    var elChedk = $('input[name="checkItem"]');
    var elId = $('input[name="Id"]');
    var Lista = [];

	for (var i = 0; i < elChedk.length; i++) {
        var checked = $(elChedk[i]).prop('checked');
        var id = $(elId[i]).val();
        if (checked) {
            Lista.push(id);
        }
    }
    return Lista;
}

function GetDadosPostAntecipacao() {

	var elChedk = $('input[name="checkItem"]');
	var elId = $('input[name="Id"]');
	var Data = "";
	var DataPagamento = $('input[name=DataPagamento]').val();
	var NovaTaxa = ($('input[name=NovaTaxa]').val() || '').replace(".", ",");
	var TipoAntecipacao = $('select[name=TipoAntecipacao]').val() || '';

	
	Data = "DataPagamento=" + DataPagamento + "&";
	Data += "NovaTaxa=" + NovaTaxa + "&";
	Data += "TipoAntecipacao=" + TipoAntecipacao + "&";


	for (var i = 0; i < elChedk.length; i++) {

		var checked = $(elChedk[i]).prop('checked');
		var id = $(elId[i]).val();
		if (checked) {
			Data += "Id="+id+"&";
		}
	}	

	return Data;
}

function CheckPostAntecipacao() {

	var elChedk = $('input[name="checkItem"]');
	var DataPagamento = $('input[name=DataPagamento]').val();
	var cont = 0;	

	if (DataPagamento == "") {
		Swal.fire({
			type: 'error',
			title: "",
			text: "Campo 'data de pagamento' e obrigatório.",
		});
		return false;
	}

	
	for (var i = 0; i < elChedk.length; i++) {
		var checked = $(elChedk[i]).prop('checked');
		if (checked) {
			cont++;
		}
	}

	if (cont == 0) {
		Swal.fire({
			type: 'error',
			title: "",
			text: "Nenhum titulos foi selecionado para criação da antecipação.",
		});
		return false;
	}

	return true;
}

function CriarAntecipacao() {

	if (CheckPostAntecipacao())
	{
		$('.btn-gerar-antecipacoes').attr('disabled', true).text("Processando...");

		$.ajax({
			type: "POST",
			url: '../Fornecedor/Antecipacao/CreateAntecipacao',
			data: GetDadosPostAntecipacao(),
			success: function (d) {

				$('.btn-gerar-antecipacoes').attr('disabled', false).text("Gerar Antecipações");

				var type = ""
				var text = ""

				if (d.ok) {
					type = "success";
					text = "Antecipações criada com sucesso.";

					myTable.ajax.reload();
				} else {
					type = "error"
					text = d.mensagem
				}

				Swal.fire({
					type: type,
					title: "",
					text: text,
				});

			},
			dataType: 'json'
		});
	}
}



$(function () {

	$('select[name=TipoAntecipacao]').on('change', function () {
		$('input[name=NovaTaxa]').attr('disabled', false);
		$('input[name=AtualizarCadastro]').attr('disabled', false);
		if ($(this).val() == '1') {
			$('input[name=NovaTaxa]').attr('disabled', true);
			$('input[name=AtualizarCadastro]').attr('disabled', true);
		}
	});

	$('select[name=TipoListagem]').on('change', function () {
		if ($.fn.DataTable.isDataTable('#myTable')) {
			myTable.clear()
			myTable.destroy();
		}
		CreateDataTable();
	});

	LoadSelect2Fornecedor();

	$('.btn-filtrar').on('click', function () {

		if ($.fn.DataTable.isDataTable('#myTable')) {
			$('#myTable').DataTable().clear();
			myTable.ajax.reload();
		} else {
			CreateDataTable();
		}
		
	});

	if (DataInicio != "") {
		CreateDataTable();
	}

	$('.btn-gerar-antecipacoes').on('click', function () {
		CriarAntecipacao();
	});


	$('#myTable tbody').on('click', 'td.group-titulo', function () {
		var name = $(this).closest('tr').data('name-group');

		var has = $('tr.' + name).closest('tr').hasClass('hide');
		if (has) {
			$('tr.' + name).closest('tr').removeClass('hide');
		} else {
			$('tr.' + name).closest('tr').addClass('hide');
		}

	});

	$('.checkAll').on('click', function () {
		var checked = $(this).is(':checked');
		var elChedk = $('input[name="checkItem"]');

		for (var i = 0; i < elChedk.length; i++) {
			$(elChedk[i]).prop('checked', checked)
		}

		SomaTitulos();
	});

	//checkAll
	$('#myTable').on('click', 'input[name="checkItem"]', function () {
		SomaTitulos()
	});


	$('input[name="FiltrarGrid"]').on('keyup', function () {

		var value = $(this).val();
		
	
		var tbody = $('#myTable tbody tr');

		for (var i = 0; i < tbody.length; i++) {
			var tds = $(tbody[i]).find('td');
			var tdok = false;

			if ($.trim(value) != "") {
				for (var j = 1; j < tds.length; j++) {
					var result = $(tds[j]).text().toLowerCase().indexOf(value.toLowerCase())
					if (result >= 0) {
						tdok = true;
						break;
					}
				}
			}
			
			$(tbody[i]).removeClass('hide');
			if ($.trim(value) != "") {
				if (!tdok) {
					$(tbody[i]).addClass('hide')
				}
			}
		}


	});

	$('#myTable').on('click', '.checkAllGrupo', function () {

		var group = $(this).closest('tr').attr('data-name-group')
		var elChedk = $(this).closest('tr').closest('tbody').find('.' + group);

		var checked = $(this).is(':checked');
		
		for (var i = 0; i < elChedk.length; i++) {
			$(elChedk[i]).find('input[name="checkItem"]').prop('checked', checked)
		}

	})
	

});


function CreateDataTable() {
	var loopCheckItem = 0;

	rowGroup = null;

	if ($('select[name=TipoListagem]').val() == '2') {
		rowGroup = {
			dataSrc: "nomeFornecedor",
			startRender: function (rows, group) {

				var d = rows.data();
				var groupclass = "";
				rows.nodes().each(function (r) {
					groupclass = 'group-' + d[0].fornecedorId
					$(this).addClass('hide').addClass(groupclass)
				});


				var somaValor = 0;
				var somaValorAnt = 0;
				var taxa = 0;
				for (var i = 0; i < d.length; i++) {
					vals = d[i];

					v = vals.valorTitulo.replace("R$", "")
					v = v.replace(".", "").replace(",", ".");
					somaValor += parseFloat(v)

					v = vals.valorAntecipado.replace("R$", "")
					v = v.replace(".", "").replace(",", ".");

					somaValorAnt += parseFloat(v);
					taxa = vals.taxa;
				}
				var colspan = 5;
				if (typeof TipoUsuario !== 'undefined' && TipoUsuario == 1) {
					colspan = 4;
				}

				var html = '';
				html += '<div class="custom-control custom-checkbox mt-3 mr-3 order-1">'
				html += '<input type="checkbox" class="custom-control-input checkAllGrupo" checked="checked" id="checkAllGrupo' + groupclass+'">'
				html += '	<label class="custom-control-label" for="checkAllGrupo' + groupclass +'"></label>'
				html += group
				html += '</div>'
				//

				return $('<tr/>')
					.append('<td class="group-titulo" colspan="' + colspan + '" style="cursor:pointer">' + html + '</td>')
					.append('<td>' + taxa  + '</td>')
					.append('<td>' + somaValor.formatNumber(2, "R$", ".", ",") + '</td>')
					.append('<td>' + somaValorAnt.formatNumber(2, "R$", ".", ",") + '</td>')
					.attr('data-name', group)
					.attr('data-name-group', groupclass);
			}
		};
		
	}

	columnsDataTable = [
		{
			"render": function (data, type, full, meta) {
				var html = '<div class="custom-control custom-checkbox mr-3 order-1">'
				html += '<input type="hidden" name="Id" value="' + full.id + '">'
				html += '<input type="checkbox" name="checkItem" checked class="custom-control-input" id="checkItem' + loopCheckItem + '">'
				html += '<label class="custom-control-label" for="checkItem' + loopCheckItem + '"></label>'
				html += '</div>'
				loopCheckItem++;
				return html;
			}
		},
		{
			"data": "nomeFornecedor", "name": "NomeFornecedor"
		},

		{
			"data": "numeroDocumento", "name": "NumeroDocumento"
		},
		{
			"data": "dataEmissao", "name": "DataEmissao"
		},
		{
			"data": "dataVencimento", "name": "DataVencimento"
		},
		{
			"data": "taxa", "name": "Taxa"
		},
		{
			"data": "valorTitulo", "name": "ValorTitulo"
		},
		{
			"data": "valorAntecipado", "name": "ValorAntecipado"
		}
	];

	if (typeof TipoUsuario !== 'undefined' && TipoUsuario == 1) {
		columnsDataTable.splice(1, 1)//remove coluna fornecedor
	}



	myTable = $('#myTable').DataTable({
		'columnDefs': [{ "orderable": false, "targets": 0 }],
		"order": [[1, "asc"]],
		rowGroup: rowGroup,
		"drawCallback": function (settings) {
			SomaTitulos();

		},
		orderCellsTop: true,
		fixedHeader: false,
		dom: "<'row mb-3'<'col-sm-12 col-md-6 d-flex align-items-center justify-content-start'B><'col-sm-12 col-md-6 d-flex align-items-center justify-content-end'l>>" +
			"<'row'<'col-sm-12'tr>>" +
			"<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7'p>>",
		buttons: [
		],
		"scrollY": "400px",
		"scrollCollapse": true,
		"paging": false,
		"responsive": true,
		"processing": true,
		"serverSide": true,
		"ajax": {
			"url": "../Fornecedor/TituloPagar/DataTable",
			"type": "POST",
			"datatype": "json",
			"data": {
				DataVencimentoInicio: function () {
					return $('input[name=DataVencimentoInicio]').val();
				},
				DataVencimentoFim: function () {
					return $('input[name=DataVencimentoFim]').val();
				},
				TipoAntecipacaoFornecedor: function () {
					return $('select[name=TipoAntecipacaoFornecedor]').val();
				},
				Fornecedores: function () {
					return $('select[name=Fornecedores]').val();
				},
				UnidadeID: function () {
					return $('select[name=UnidadeID]').val();
				},
				DataPagamento: function () {
					return $('input[name=DataPagamento]').val();
				},
				NovaTaxa: function () {
					return ($('input[name=NovaTaxa]').val() || '').replace(".", ",");
				},
				Analise: function () {
					return "";
				},
				TipoAntecipacao: function () {
					return $('select[name=TipoAntecipacao]').val()|| '';
                }
				/*FieldSearch: function () {
					return $('input[name=FieldSearch]').val()
				},*/
			},
		},

		"columns": columnsDataTable,
		"bLengthChange": false,
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
			"sEmptymyTable": "Não há dados disponíveis na tabela",
			"sLoadingRecords": "Carregando...",
			"sProcessing": "Processando..."
		},
	});



	
}

function SomaTitulos() {

	var elChedk = $('input[name="checkItem"]');
	var elId = $('input[name="Id"]');

	var Dados = myTable.data();
	var somaValor = 0;
	var somaValorAnt = 0;

	for (var i = 0; i < elChedk.length; i++) {
		var checked = $(elChedk[i]).prop('checked');

		if (checked) {

			vals = Dados[i]

			v = vals.valorTitulo.replace("R$", "")
			v = v.replace(".", "").replace(",", ".");
			somaValor += parseFloat(v)

			v = vals.valorAntecipado.replace("R$", "")
			v = v.replace(".", "").replace(",", ".");

			somaValorAnt += parseFloat(v)


		}
	}

	$('input[name=TotalBruto]').val(somaValor.formatNumber(2, "", ".", ","));
	$('input[name=TotalLiquido]').val(somaValorAnt.formatNumber(2, "", ".", ","));
	$('input[name=TotalGanho]').val((somaValor - somaValorAnt).formatNumber(2, "", ".", ","));
}