var table;


function GetBoleto() {
    var el = $('input[name=checkItem]');
    var Id = "";
    for (var i = 0; i < el.length; i++) {
        if ($(el[i]).prop('checked')) {
            if (Id != "") {
                Id += ",";
            }
            Id += $(el[i]).closest('div.check-item').find('input[name="Id"]').val();
        }
    }
    return Id;
}


function GetBoletoId() {

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


    } else {
        Swal.fire({
            type: 'error',
            title: "",
            text: "Selecione apenas um boleto.",
        });
    }
    return "";
}


function ImprimirBoleto() {

    CheckAtualizacao(function () {
        var page = $('.new-page').attr('page')
        $('.new-page').attr('href', page + '/Imprimir?Id=' + GetBoleto());
        $('.new-page')[0].click();
    }, "/CheckImprimir");

}


function ExportarExcel(func) {

    var bolIds = GetBoleto();

    var page = $('.new-page').attr('page')

    if (bolIds === "")
        $('.new-page').attr('href', page + '/ExportarExcel');
    else
        $('.new-page').attr('href', page + '/ExportarExcel?bolIds=' + bolIds);

    $('.new-page')[0].click();
}


function CheckAtualizacao(func, url) {

    Id = GetBoletoId();

    url = url || "/CheckAtualizacao";

    if (Id != "") {
        $.post(
            UrlBase + url,
            { Id: Id },
            function (d) {

                if (d.ok) {
                    func.call();
                }
                else {

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


$('.btn-atualizar').on('click', function () {

    $('#modal-boleto').modal('hide');

    var Acao = $('input[name=Acao]').val();

    if (Acao == 'A') {
        CheckAtualizacao(function () {
            AtualizarBoleto();
        });

    } else {
        CheckAtualizacao(function () {
            AtualizarEnviarEmailBoleto();
        });
    }

});


function CheckVencido(func) {

    Id = GetBoletoId();
    $('input[name=DataAtualizacao]').val('');

    if (Id != "") {

        $.post(
            UrlBase + "/CheckVencido",
            { Id: Id },
            function (d) {

                if (d.ok) {

                    $('#modal-boleto').modal('show');
                }
                else {
                    Swal.fire({
                        type: 'error',
                        title: "",
                        text: "O boleto selecionado não está vencido.",
                    });
                    //CheckAtualizacao(func);
                }
            }
        );
    }

}


function AtualizarBoleto() {

    $('#modal-boleto').modal('hide');
    var page = $('.new-page').attr('page')
    if ($('input[name=DataAtualizacao]').val() != "") {
        DataAtualizacao = $('input[name=DataAtualizacao]').val();
        $('.new-page').attr('href', page + '/Atualizar?Id=' + Id + "&DataAtualizacao=" + DataAtualizacao);
    } else {
        $('.new-page').attr('href', page + '/Atualizar?Id=' + Id);
    }
    $('.new-page')[0].click();

}


function EnviarEmailBoleto() {

    var page = $('.new-page').attr('page')
    $('.new-page').attr('href', page + '/EnviarEmail?Id=' + GetBoleto());
    $('.new-page')[0].click();

}


function AtualizarEnviarEmailBoleto() {

    var page = $('.new-page').attr('page')
    if ($('input[name=DataAtualizacao]').val() != "") {
        DataAtualizacao = $('input[name=DataAtualizacao]').val();
		$('.new-page').attr('href', page + '/AtualizarEnviarEmail?Id=' + Id + "&DataAtualizacao=" + DataAtualizacao);
    } else {
		$('.new-page').attr('href', page + '/AtualizarEnviarEmail?Id=' + Id);
    }
    $('.new-page')[0].click();
    $('#modal-boleto').modal('hide');

}


var loopCheckItem = 0;


$(document).ready(function () {

    var table = $('#dt-registro').DataTable(
        {
            'columnDefs': [{ "orderable": false, "targets": 0 }],
            "order": [[5, "asc"]],
            orderCellsTop: true,
            fixedHeader: true,
            dom: "<'row mb-3'<'col-sm-12 col-md-8 d-flex align-items-center justify-content-start'B><'col-sm-12 col-md-4 d-flex align-items-center justify-content-end'l>>" +
                "<'row'<'col-sm-12'tr>>" +
                "<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7'p>>",
            buttons: ButtonsAcoes,
            "responsive": true,
            "processing": true,
            "serverSide": true,
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
                    "data": "sacado", "name": "Sacado"
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

    var CamposFiltro = ['NomeUnidade', 'Sacado', 'NumeroDocumento', 'DataEmissao', 'DataVencimento', 'Status', 'ValorTitulo'];
    $('#dt-registro thead tr').clone(false).appendTo('#dt-registro thead');
    $('#dt-registro thead tr:eq(1) th').each(function (i) {

        $(this).removeClass('sorting');
        if (i > 0) {

            var title = $(this).text();

            $(this).html('<div class="form-check-inline" style="width: 100%;"><div class="" style="width: 100%;"><input type="text" name="' + CamposFiltro[i - 1] + '" class="form-control form-control-sm search" placeholder=""></div><div class="" ><div class="columnFilter filter-search" ><i class="fal fa-filter mr-1"></i></div></div>');


            $('input', this).on('keyup', function (e) {

                if (e.keyCode == 13) {
                    FuncSearch(this, table);
                }

            });


        } else {

            var html = '<div class="custom-control custom-checkbox mr-3 pb-2 order-1">'
            html += '<input type="checkbox" class="custom-control-input" id="checkAll">'
            html += '<label class="custom-control-label" for="checkAll"></label>'
            html += '</div>'

            $(this).html(html);
        }
    });

    for (var i = 0; i < CamposFiltro.length; i++) {
        $('input[name="' + CamposFiltro[i] + '"]').val('');
    }

    $('.filter-search').on('click', function () {


        FuncSearch(this, table);
    });

    $('.filter-close').on('click', function () {
        $(this).closest('th').find('input').val('');
        FuncSearch(table);
    });


});

