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
				
			],
            "ajax": {
                "url": "../AdminEmpresa/Fornecedor/DataTable",
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
                    "data": "cpfcnpj", "name": "CPFCNPJ"
                },
                {
                    "data": "codigoERP", "name": "CodigoERP"
                },
                {
                    "data": "nome", "name": "Nome"
                },
                {
                    "data": "email", "name": "Email"
                },
                {
                    "data": "bairro", "name": "Bairro"
                },
                {
                    "data": "cidade", "name": "Cidade"
                },
                {
                    "data": "uf", "name": "UF"
                },
                {
                    "render": function (data, type, full, meta) {

                        var html = '';

                        
                        html += '<div class="d-flex demo">'
                        
                        html += '<a title="Criar/Resetar Usuário" href="javascript:void(0)" pessoaid="' + full.id + '" empresaid="' + full.empresaID + '" class="btn btn-icon fs-xl waves-effect waves-themed btn-criar-reset" >'
                        html += '<i class="fal fa-user color-fusion-300"></i>'
                        html += '</a>'

                        html += '<a title="Ações FIDC" href="javascript:void(0)" pessoaid="' + full.id + '" empresaid="' + full.empresaID + '" class="btn btn-icon fs-xl waves-effect waves-themed btn-acoes-fidc" >'
                        html += '<i class="fal fa-edit color-fusion-300"></i>'
                        html += '</a>'

                      //  html += '<a title="Anexos" href="javascript:void(0)" pessoaid="' + full.id + '" empresaid="' + full.empresaID + '" class="btn btn-icon fs-xl waves-effect waves-themed btn-anexo" >'
                      //  html += '<i class="fal fa-upload color-fusion-300"></i>'
                      //  html += '</a>'

                     //   html += '<a title="Salvar Arquivo Pasta FIDC" href="javascript:void(0)" pessoaid="' + full.id + '" empresaid="' + full.empresaID + '" class="btn btn-icon fs-xl waves-effect waves-themed btn-salvar-anexo-fidc" >'
                     //   html += '<i class="fal fa-cog color-fusion-300"></i>'
                     //   html += '</a>'

                        
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


    var CamposFiltro = ['CPFCNPJ', 'CodigoERP', 'Nome', 'Email', 'Bairro', 'Cidade', 'UF'];
    $('#dt-registro thead tr').clone(false).appendTo('#dt-registro thead');
    $('#dt-registro thead tr:eq(1) th').each(function (i) {

        $(this).removeClass('sorting');
        if (i < CamposFiltro.length) {

            var title = $(this).text();
            $(this).html('<div class="form-check-inline" style="width: 100%;"><div class="" style="width: 100%;"><input type="text" name="' + CamposFiltro[i] + '" class="form-control form-control-sm search" placeholder=""></div><div class=""><div class="columnFilter filter-search"><i class="fal fa-filter mr-1"></i></div></div>');


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


    $('#dt-registro').on('click', '.btn-criar-reset', function () {
		RegisterOrResetAsync($(this).attr('empresaid'), $(this).attr('pessoaid'))
    });

    
    /*$('#dt-registro').on('click', 'a.btn-salvar-anexo-fidc', function () {
        SalvarAnexoFIDC(this)
    });
    */
/*$('.btn-salvar-documento').on('click', function () {
    SalvarAnexoFornecedor();
});
*/

    $('.btn-salvar-anexo-fidc').on('click', function () {
        SalvarAnexoFIDC()
    });

    $('#dt-registro').on('click', 'a.btn-acoes-fidc', function () {
        ShowModalAcoesFIDC(this)
    });

    $('#dt-registro').on('click', 'a.btn-anexo', function () {
        ShowModalAnexoFornecedor(this)
    });

    $('.btn-novo-anexo').on('click', function () {
         AdicionarAnexo('tabela-novo-anexo');
    });

    
    $('.btn-salvar-acoes-fidc').on('click', function () {
        SalvarAcoesFIDC();
    });

    $("#tabela-novo-anexo").on("click", ".btn-delete-anexo",
        function () {
            var tr = $(this).closest('tr');
            tr.fadeOut(100, function () {
                tr.remove();
            });
        }
    );

    $("#tabela-novo-anexo").on("click", ".btn-delete-anexo-list",
        function () {
            RemoveAnexoFornecedor(this)
        }
    );

    $('#tabela-novo-anexo').on('change', 'input[name=Arquivo]', function () {
        var val = $(this).val();

        $(this).closest('div.custom-file').find('.nome-arquivo').remove();
        if (val != "") {
            $(this).closest('div.custom-file').append('<div class="nome-arquivo">' + val + '</div>');
        }
    });
});


function ShowModalAnexoFornecedor(el) {
    
    LoadAnexoFornecedor(el);
}

function SalvarAnexoFIDC() {

    //var Id = $(el).attr('pessoaid');

    var Id = $("form[name=cadAcoesFIDCFornecedor] input[name='FornecedorID']").val();
    $('#modal-acoes-fidc').modal('hide');
    $('#preloader').removeClass('hide');
    $('#preloader div#status').html('Aguarde...');


    $.get(
        '../AdminEmpresa/Fornecedor/SalvarListAnexo?_=' + new Date().getTime(),
        { Id: Id },
        function (d) {
            $('#preloader').addClass('hide');

            var type = "";
            var text = d.mensagem;

            if (d.ok) {
                type = "success";
            } else {
                type = "error";
            }

            Swal.fire({
                type: type,
                title: "",
                text: text,
            });

        }
    );
}

function ShowModalAcoesFIDC(el) {

    var Id = $(el).attr('pessoaid');
    $("form[name=cadAcoesFIDCFornecedor] input[name='FornecedorID']").val(Id);

    $('#preloader').removeClass('hide');
    $('#preloader div#status').html('Aguarde...');
    
    $.get(
        '../AdminEmpresa/Fornecedor/GetAcoesFIDC?_=' + new Date().getTime(),
        { Id: Id },
        function (d) {

            if (d.ok) {
                if (d.result) {
                    $('select[name=FIDCAtivo]').val(d.result.fidcAtivo ? '1' : 0);
                    $('select[name=AntecipaServico]').val(d.result.antecipaServico ? '1' : 0);

                    html = "";
                    for (var i = 0; i < d.result.anexo.length; i++) {
                        html += '<tr>'
                        html += '<td><a target="_blank" href="../AdminEmpresa/Fornecedor/GetAnexo/' + d.result.anexo[i].id + '" class="" >' + d.result.anexo[i].nome + '</a></td>'
                        html += '<td class="text-right"><a href="javascript:void(0)" id="' + d.result.anexo[i].id + '" class="btn btn-icon fs-xl waves-effect waves-themed btn-delete-anexo-list" ><i class="fal fa-trash-alt color-fusion-300"></i></a></td>'
                        html += '</tr>'
                    }
                    $('#tabela-novo-anexo tbody').html(html);

                }
            }

            $('#preloader').addClass('hide');

            
            $('#modal-acoes-fidc').modal('show');
        }
    );

}

function RemoveAnexoFornecedor(el) {

    var Id = $(el).closest('a').attr('id');
    $('#modal-acoes-fidc').modal('hide');
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
                    '../AdminEmpresa/Fornecedor/RemoverAnexo',
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



function SalvarAcoesFIDC() {

    //var Id = $("form[name=cadAcoesFIDCFornecedor] input[name='FornecedorID']").val();
    //var FIDCAtivo = $("form[name=cadAcoesFIDCFornecedor] select[name='FIDCAtivo']").val();
    //var AntecipaServico = $("form[name=cadAcoesFIDCFornecedor] select[name='AntecipaServico']").val();

    $('#modal-acoes-fidc').modal('hide');

    Swal.fire(
        {
            text: "Deseja salvar as informações?",
            type: "warning",
            showCancelButton: true,
            confirmButtonText: "Sim",
            cancelButtonText: "Não"
        }).then(function (result) {
            if (result.value) {

                $('#preloader').removeClass('hide');
                $('#preloader div#status').html('Aguarde...');

                var formdata = new FormData($('#cadAcoesFIDCFornecedor')[0]);

                $.ajax({
                    type: 'POST',
                    url: '../AdminEmpresa/Fornecedor/SalvarAcoesFIDC',
                    data: formdata,
                    processData: false,
                    contentType: false
                }).done(function (d) {

                    $('#preloader').addClass('hide');

                    var type = ""
                    var text = ""

                    if (d.ok) {
                        type = "success";
                        text = "Informação gravada com sucesso.";
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

                /*$.post(
                    '../AdminEmpresa/Fornecedor/SalvarAcoesFIDC',
                    { Id: Id, FIDCAtivo: (FIDCAtivo == '1' ? true : false), AntecipaServico: (AntecipaServico == '1' ? true : false)},
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
                */
            }
        });
}

function LoadAnexoFornecedor(el) {

    var Id = $(el).attr('pessoaid');
    $("form[name=cadAnexoFornecedor] input[name='FornecedorID']").val(Id);

    $('#preloader').removeClass('hide');
    $('#preloader div#status').html('Aguarde...');
    $('#tabela-novo-anexo tr').find('input[name=Arquivo]').closest('tr').remove();

    $.get(
        '../AdminEmpresa/Fornecedor/GetListAnexo?_=' + new Date().getTime(),
        { Id: Id },
        function (d) {

            $('#preloader').addClass('hide');

            html = "";
            if (d.ok) {
                for (var i = 0; i < d.result.length; i++) {
                    html += '<tr>'
                    html += '<td><a target="_blank" href="../AdminEmpresa/Fornecedor/GetAnexo/' + d.result[i].id + '" class="" >' + d.result[i].nome + '</a></td>'
                    html += '<td class="text-right"><a href="javascript:void(0)" id="' + d.result[i].id + '" class="btn btn-icon fs-xl waves-effect waves-themed btn-delete-anexo-list" ><i class="fal fa-trash-alt color-fusion-300"></i></a></td>'
                    html += '</tr>'
                }
            }

            $('#tabela-novo-anexo tbody').html(html);

            $('#modal-anexo-fornecedor').modal('show');
        }
    );
}


function SalvarAnexoFornecedor() {

    $('#modal-acoes-fidc').modal('hide');
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

                var formdata = new FormData($('#cadAcoesFIDCFornecedor')[0]);

                $.ajax({
                    type: 'POST',
                    url: '../AdminEmpresa/Fornecedor/SalvarAnexo',
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

    var tipo = ['file', 'html'];
    var nome = [ 'Arquivo', ''];
    var id = ['Arquivo' + loopAnexo, ''];
    var valor = [ "", '<a href="javascript:void(0)" class="btn btn-icon fs-xl waves-effect waves-themed btn-delete-anexo" ><i class="fal fa-trash-alt color-fusion-300"></i></a>'];
    var estilo = ["custom-file-input", ""];
    var estiloCell = [ "", "center"];
    var colspanCell = [ "", ""];
    var outros = ["style='width: 60%'", ""];
    addRow(tabela, tipo, nome, id, valor, estilo, outros, estiloCell, colspanCell, colspanCell);
    loopAnexo++;
}

function RegisterOrResetAsync(empresaId, pessoaId) {
    $.get(
        '../Account/RegisterOrResetAsync',
		{ empresaId: empresaId, pessoaId: pessoaId, tipo: 3 },
        function (d) {
            Swal.fire({
                type: d.ok ? 'success' : 'error',
                title: "",
                text: d.ok ? 'Usuário criado/resetado com sucesso.' : 'Erro ao criar/resetar usuário.',
            });
        }
    );
}