# OatBioDB celery task
def samtools_extract_fasta(fasta_file, pos):
    """
    samtools faidx sang_longiglumis.fasta.gz chr1A:1-10
    """
    cmd = samtools + ' faidx ' + \
        fasta_file + ' ' + pos
    p = Popen(cmd, shell=True, stdout=PIPE, stderr=PIPE)
    stdout, stderr = p.communicate()
    result = stdout.decode('utf-8')
    return result


def samtools_extract_id_fasta(fasta_file, id):
    """
    samtools faidx sang_longiglumis_cds.gz A.sang_2928282.1 
    """
    cmd = samtools + ' faidx ' + \
        fasta_file + ' ' + id
    p = Popen(cmd, shell=True, stdout=PIPE, stderr=PIPE)
    stdout, stderr = p.communicate()
    result = stdout.decode('utf-8')
    print(stderr.decode('utf-8'))
    return result
# samtools ######################################################


@shared_task
def exseq_pos(fasta_file, chr_name, start, end):
    pos = chr_name + ':' + str(start) + '-' + str(end)
    sequence = samtools_extract_fasta(fasta_file, pos)
    return sequence


@shared_task
def exseq_pos_list(fasta_file: str, pos_list: list):
    sequence = samtools_extract_fasta(fasta_file, ' '.join(pos_list))
    return sequence


@shared_task
def exseq_id(fasta_file, id):
    sequence = samtools_extract_id_fasta(fasta_file, id)
    return sequence


@shared_task
def go_celery(BASE_DIR: str, MEDIA_ROOT: str, R_path: str, R_lib: str, org_db: str, p_value: float, q_value: float, gene_list: list, go_type: str, width: float, height: float, dpi: int):
    go_dir_path = MEDIA_ROOT + '/useroperation/files/go/' + go_celery.request.id
    go_cript_path = BASE_DIR + '/tools/GO/' + 'goEnrich.R'
    try:
        os.mkdir(go_dir_path)
    except Exception as e:
        print(e)

    input_tsv = go_dir_path + '/' + 'gene_list.tsv'
    f = open(input_tsv, 'w')
    for i in gene_list:
        f.write(i + '\n')
    f.close()

    os.chdir(MEDIA_ROOT + '/useroperation/files/go/')

    result_detail = go_enrich(R_path=R_path, R_script=go_cript_path, gene_list=input_tsv, org_db=org_db,
                              p_value=p_value, q_value=q_value, r_lib=R_lib, go_type=go_type, width=width, height=height, dpi=dpi, output_name=go_celery.request.id)

    # os.chdir(MEDIA_ROOT + '/useroperation/files/go/')
    result_relate_path = './' + go_celery.request.id + '/'
    gz_detail = gz_files(result_relate_path,
                         go_celery.request.id + '.tar.gz')
    return gz_detail, result_detail


@shared_task
def kegg_celery(BASE_DIR: str, MEDIA_ROOT: str, R_path: str, R_lib: str, org_db: str, p_value: float, q_value: float, gene_list: list, width: float, height: float, dpi: int):
    kegg_dir_path = MEDIA_ROOT + '/useroperation/files/kegg/' + kegg_celery.request.id
    kegg_cript_path = BASE_DIR + '/tools/KEGG/' + 'keggEnrich.R'
    kegg_ko = BASE_DIR + '/tools/KEGG/' + 'kegg_ko_annotation.tsv'
    try:
        os.mkdir(kegg_dir_path)
    except Exception as e:
        print(e)

    input_tsv = kegg_dir_path + '/' + 'gene_list.tsv'
    f = open(input_tsv, 'w')
    for i in gene_list:
        f.write(i + '\n')
    f.close()

    os.chdir(MEDIA_ROOT + '/useroperation/files/kegg/')

    result_detail = kegg_enrich(R_path=R_path, R_script=kegg_cript_path, kegg_ko=kegg_ko, gene_list=input_tsv, org_db=org_db,
                                p_value=p_value, q_value=q_value, r_lib=R_lib, width=width, height=height, dpi=dpi, output_name=kegg_celery.request.id)

    # os.chdir(MEDIA_ROOT + '/useroperation/files/kegg/')
    result_relate_path = './' + kegg_celery.request.id + '/'
    gz_detail = gz_files(result_relate_path,
                         kegg_celery.request.id + '.tar.gz')
    return gz_detail, result_detail
