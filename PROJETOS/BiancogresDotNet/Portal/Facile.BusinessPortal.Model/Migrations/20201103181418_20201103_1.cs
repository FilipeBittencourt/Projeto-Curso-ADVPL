using System;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _20201103_1 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "RPVMedicao");

            migrationBuilder.DropTable(
                name: "RPV");

            migrationBuilder.CreateTable(
                name: "Atendimento",
                columns: table => new
                {
                    ID = table.Column<long>(nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    InsertUser = table.Column<string>(nullable: true),
                    InsertDate = table.Column<DateTime>(nullable: true),
                    LastEditUser = table.Column<string>(nullable: true),
                    LastEditDate = table.Column<DateTime>(nullable: true),
                    StatusIntegracao = table.Column<int>(nullable: false),
                    DataHoraIntegracao = table.Column<DateTime>(nullable: true),
                    MensagemRetorno = table.Column<string>(nullable: true),
                    EmpresaID = table.Column<long>(nullable: false),
                    UnidadeID = table.Column<long>(nullable: true),
                    Habilitado = table.Column<bool>(nullable: false),
                    Deletado = table.Column<bool>(nullable: false),
                    DeleteID = table.Column<long>(nullable: false),
                    IDProcesso = table.Column<Guid>(nullable: true),
                    StageID = table.Column<long>(nullable: true),
                    FornecedorID = table.Column<long>(nullable: false),
                    Numero = table.Column<string>(nullable: true),
                    NumeroContrato = table.Column<string>(nullable: true),
                    Item = table.Column<string>(nullable: true),
                    CodigoProduto = table.Column<string>(nullable: true),
                    NomeProduto = table.Column<string>(nullable: true),
                    QuantidadeProduto = table.Column<decimal>(nullable: false),
                    Contato = table.Column<string>(nullable: true),
                    Email = table.Column<string>(nullable: true),
                    Observacao = table.Column<string>(nullable: true),
                    DataLiberacao = table.Column<DateTime>(nullable: false),
                    NumeroControleParticipante = table.Column<string>(nullable: true),
                    Status = table.Column<int>(nullable: false),
                    DataMedicao = table.Column<DateTime>(nullable: true),
                    UsuarioID = table.Column<long>(nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Atendimento", x => x.ID);
                    table.ForeignKey(
                        name: "FK_Atendimento_Empresa_EmpresaID",
                        column: x => x.EmpresaID,
                        principalTable: "Empresa",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Atendimento_Fornecedor_FornecedorID",
                        column: x => x.FornecedorID,
                        principalTable: "Fornecedor",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Atendimento_Unidade_UnidadeID",
                        column: x => x.UnidadeID,
                        principalTable: "Unidade",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Atendimento_Usuario_UsuarioID",
                        column: x => x.UsuarioID,
                        principalTable: "Usuario",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "AtendimentoMedicao",
                columns: table => new
                {
                    ID = table.Column<long>(nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    InsertUser = table.Column<string>(nullable: true),
                    InsertDate = table.Column<DateTime>(nullable: true),
                    LastEditUser = table.Column<string>(nullable: true),
                    LastEditDate = table.Column<DateTime>(nullable: true),
                    StatusIntegracao = table.Column<int>(nullable: false),
                    DataHoraIntegracao = table.Column<DateTime>(nullable: true),
                    MensagemRetorno = table.Column<string>(nullable: true),
                    EmpresaID = table.Column<long>(nullable: false),
                    UnidadeID = table.Column<long>(nullable: true),
                    Habilitado = table.Column<bool>(nullable: false),
                    Deletado = table.Column<bool>(nullable: false),
                    DeleteID = table.Column<long>(nullable: false),
                    IDProcesso = table.Column<Guid>(nullable: true),
                    StageID = table.Column<long>(nullable: true),
                    AtendimentoID = table.Column<long>(nullable: false),
                    Nome = table.Column<string>(nullable: true),
                    Tipo = table.Column<string>(nullable: true),
                    Descricao = table.Column<string>(nullable: true),
                    Arquivo = table.Column<byte[]>(nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AtendimentoMedicao", x => x.ID);
                    table.ForeignKey(
                        name: "FK_AtendimentoMedicao_Atendimento_AtendimentoID",
                        column: x => x.AtendimentoID,
                        principalTable: "Atendimento",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_AtendimentoMedicao_Empresa_EmpresaID",
                        column: x => x.EmpresaID,
                        principalTable: "Empresa",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_AtendimentoMedicao_Unidade_UnidadeID",
                        column: x => x.UnidadeID,
                        principalTable: "Unidade",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Atendimento_EmpresaID",
                table: "Atendimento",
                column: "EmpresaID");

            migrationBuilder.CreateIndex(
                name: "IX_Atendimento_FornecedorID",
                table: "Atendimento",
                column: "FornecedorID");

            migrationBuilder.CreateIndex(
                name: "IX_Atendimento_UnidadeID",
                table: "Atendimento",
                column: "UnidadeID");

            migrationBuilder.CreateIndex(
                name: "IX_Atendimento_UsuarioID",
                table: "Atendimento",
                column: "UsuarioID");

            migrationBuilder.CreateIndex(
                name: "IX_AtendimentoMedicao_AtendimentoID",
                table: "AtendimentoMedicao",
                column: "AtendimentoID");

            migrationBuilder.CreateIndex(
                name: "IX_AtendimentoMedicao_EmpresaID",
                table: "AtendimentoMedicao",
                column: "EmpresaID");

            migrationBuilder.CreateIndex(
                name: "IX_AtendimentoMedicao_UnidadeID",
                table: "AtendimentoMedicao",
                column: "UnidadeID");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "AtendimentoMedicao");

            migrationBuilder.DropTable(
                name: "Atendimento");

            migrationBuilder.CreateTable(
                name: "RPV",
                columns: table => new
                {
                    ID = table.Column<long>(nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    CodigoProduto = table.Column<string>(nullable: true),
                    Contato = table.Column<string>(nullable: true),
                    DataHoraIntegracao = table.Column<DateTime>(nullable: true),
                    DataLiberacao = table.Column<DateTime>(nullable: false),
                    DataMedicao = table.Column<DateTime>(nullable: true),
                    Deletado = table.Column<bool>(nullable: false),
                    DeleteID = table.Column<long>(nullable: false),
                    Email = table.Column<string>(nullable: true),
                    EmpresaID = table.Column<long>(nullable: false),
                    FornecedorID = table.Column<long>(nullable: false),
                    Habilitado = table.Column<bool>(nullable: false),
                    IDProcesso = table.Column<Guid>(nullable: true),
                    InsertDate = table.Column<DateTime>(nullable: true),
                    InsertUser = table.Column<string>(nullable: true),
                    Item = table.Column<string>(nullable: true),
                    LastEditDate = table.Column<DateTime>(nullable: true),
                    LastEditUser = table.Column<string>(nullable: true),
                    MensagemRetorno = table.Column<string>(nullable: true),
                    NomeProduto = table.Column<string>(nullable: true),
                    Numero = table.Column<string>(nullable: true),
                    NumeroContrato = table.Column<string>(nullable: true),
                    NumeroControleParticipante = table.Column<string>(nullable: true),
                    Observacao = table.Column<string>(nullable: true),
                    QuantidadeProduto = table.Column<decimal>(nullable: false),
                    StageID = table.Column<long>(nullable: true),
                    Status = table.Column<int>(nullable: false),
                    StatusIntegracao = table.Column<int>(nullable: false),
                    UnidadeID = table.Column<long>(nullable: true),
                    UsuarioID = table.Column<long>(nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_RPV", x => x.ID);
                    table.ForeignKey(
                        name: "FK_RPV_Empresa_EmpresaID",
                        column: x => x.EmpresaID,
                        principalTable: "Empresa",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_RPV_Fornecedor_FornecedorID",
                        column: x => x.FornecedorID,
                        principalTable: "Fornecedor",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_RPV_Unidade_UnidadeID",
                        column: x => x.UnidadeID,
                        principalTable: "Unidade",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_RPV_Usuario_UsuarioID",
                        column: x => x.UsuarioID,
                        principalTable: "Usuario",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "RPVMedicao",
                columns: table => new
                {
                    ID = table.Column<long>(nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    Arquivo = table.Column<byte[]>(nullable: true),
                    DataHoraIntegracao = table.Column<DateTime>(nullable: true),
                    Deletado = table.Column<bool>(nullable: false),
                    DeleteID = table.Column<long>(nullable: false),
                    Descricao = table.Column<string>(nullable: true),
                    EmpresaID = table.Column<long>(nullable: false),
                    Habilitado = table.Column<bool>(nullable: false),
                    IDProcesso = table.Column<Guid>(nullable: true),
                    InsertDate = table.Column<DateTime>(nullable: true),
                    InsertUser = table.Column<string>(nullable: true),
                    LastEditDate = table.Column<DateTime>(nullable: true),
                    LastEditUser = table.Column<string>(nullable: true),
                    MensagemRetorno = table.Column<string>(nullable: true),
                    Nome = table.Column<string>(nullable: true),
                    RPVID = table.Column<long>(nullable: false),
                    StageID = table.Column<long>(nullable: true),
                    StatusIntegracao = table.Column<int>(nullable: false),
                    Tipo = table.Column<string>(nullable: true),
                    UnidadeID = table.Column<long>(nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_RPVMedicao", x => x.ID);
                    table.ForeignKey(
                        name: "FK_RPVMedicao_Empresa_EmpresaID",
                        column: x => x.EmpresaID,
                        principalTable: "Empresa",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_RPVMedicao_RPV_RPVID",
                        column: x => x.RPVID,
                        principalTable: "RPV",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_RPVMedicao_Unidade_UnidadeID",
                        column: x => x.UnidadeID,
                        principalTable: "Unidade",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_RPV_EmpresaID",
                table: "RPV",
                column: "EmpresaID");

            migrationBuilder.CreateIndex(
                name: "IX_RPV_FornecedorID",
                table: "RPV",
                column: "FornecedorID");

            migrationBuilder.CreateIndex(
                name: "IX_RPV_UnidadeID",
                table: "RPV",
                column: "UnidadeID");

            migrationBuilder.CreateIndex(
                name: "IX_RPV_UsuarioID",
                table: "RPV",
                column: "UsuarioID");

            migrationBuilder.CreateIndex(
                name: "IX_RPVMedicao_EmpresaID",
                table: "RPVMedicao",
                column: "EmpresaID");

            migrationBuilder.CreateIndex(
                name: "IX_RPVMedicao_RPVID",
                table: "RPVMedicao",
                column: "RPVID");

            migrationBuilder.CreateIndex(
                name: "IX_RPVMedicao_UnidadeID",
                table: "RPVMedicao",
                column: "UnidadeID");
        }
    }
}
