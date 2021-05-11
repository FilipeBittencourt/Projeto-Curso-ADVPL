using System;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.StageArea.Model.Migrations
{
    public partial class _20201223_1 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            
            migrationBuilder.CreateTable(
                name: "RPV",
                columns: table => new
                {
                    ID = table.Column<long>(nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    ChaveUnica = table.Column<string>(nullable: false),
                    EmpresaID = table.Column<long>(nullable: false),
                    UnidadeID = table.Column<long>(nullable: true),
                    InsertUser = table.Column<string>(nullable: true),
                    InsertDate = table.Column<DateTime>(nullable: true),
                    LastEditUser = table.Column<string>(nullable: true),
                    LastEditDate = table.Column<DateTime>(nullable: true),
                    StatusIntegracao = table.Column<int>(nullable: false),
                    DataHoraIntegracao = table.Column<DateTime>(nullable: true),
                    MensagemRetorno = table.Column<string>(nullable: true),
                    FornecedorCPFCNPJ = table.Column<string>(nullable: true),
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
                    Deletado = table.Column<bool>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_RPV", x => x.ID);
                });

            migrationBuilder.CreateIndex(
                name: "IX_RPV_EmpresaID_ChaveUnica",
                table: "RPV",
                columns: new[] { "EmpresaID", "ChaveUnica" },
                unique: true);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "RPV");
        }
    }
}
