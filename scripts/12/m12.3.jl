using StatisticalRethinking
using Turing

Turing.setadbackend(:reverse_diff)

μ = 1.4
σ = 1.5
nponds = 60
ni = repeat([5,10,25,35], inner=15)

a_pond = rand(Normal(μ, σ), nponds)

dsim = DataFrame(pond = 1:nponds, ni = ni, true_a = a_pond)

prob = logistic.(Vector{Real}(dsim[:true_a]))

dsim[:si] = [rand(Binomial(ni[i], prob[i])) for i = 1:nponds]

# Used only in the continuation of this example
dsim[:p_nopool] = dsim[:si] ./ dsim[:ni]

@model m12_3(pond, si, ni) = begin

    # Separate priors on μ and σ for each pond
    σ ~ Truncated(Cauchy(0, 1), 0, Inf)
    μ ~ Normal(0, 1)

    # Number of ponds in the data set
    N_ponds = length(pond)

    # vector for the priors for each pond
    a_pond = Vector{Real}(undef, N_ponds)

    # For each pond set a prior. Note the [] around Normal(), i.e.,
    a_pond ~ [Normal(μ, σ)]

    # Observation
    logitp = [a_pond[pond[i]] for i = 1:N_ponds]
    si ~ VecBinomialLogit(ni, logitp)

end

posterior = sample(m12_3(Vector{Int64}(dsim[:pond]), Vector{Int64}(dsim[:si]),
    Vector{Int64}(dsim[:ni])), Turing.NUTS(10000, 1000, 0.8))
describe(posterior)
#                 Mean           SD        Naive SE        MCSE         ESS
# a_pond[13]    0.0177228141  0.841956449 0.0084195645 0.00771496194 10000.0000
# a_pond[39]    0.0066110725  0.403509812 0.0040350981 0.00300378764 10000.0000
# a_pond[12]   -0.6879306819  0.887142394 0.0088714239 0.00983038264  8144.1511
# a_pond[33]    1.0230070658  0.440802431 0.0044080243 0.00340565683 10000.0000
# a_pond[40]   -0.4710107332  0.397151811 0.0039715181 0.00287378746 10000.0000
#          μ    1.4171959646  0.247164994 0.0024716499 0.00279659983  7811.1193
# a_pond[52]   -0.1075137501  0.334424028 0.0033442403 0.00304380214 10000.0000
# a_pond[48]    0.2270466468  0.340522575 0.0034052258 0.00288072684 10000.0000
# a_pond[31]   -0.3116943388  0.406497387 0.0040649739 0.00327039672 10000.0000
# a_pond[21]   -0.5664379565  0.649981939 0.0064998194 0.00531522292 10000.0000
# a_pond[14]   -0.6980794242  0.863848603 0.0086384860 0.00834117683 10000.0000
# a_pond[26]    1.5157188342  0.746372296 0.0074637230 0.00689302178 10000.0000
# a_pond[35]   -0.3104176671  0.400246807 0.0040024681 0.00351529487 10000.0000
# a_pond[53]    2.3656224490  0.570317605 0.0057031760 0.00514104769 10000.0000
# a_pond[45]    3.7602403329  1.040583568 0.0104058357 0.01371112136  5759.8076
# a_pond[27]    3.1787683092  1.143238040 0.0114323804 0.01676903058  4647.9069
# a_pond[10]    2.7440414813  1.264526612 0.0126452661 0.01600961219  6238.7032
# a_pond[19]    3.1606479454  1.166461112 0.0116646111 0.01482980989  6186.8468
# a_pond[58]    3.2339626006  0.791995574 0.0079199557 0.00801476020  9764.8245
#  a_pond[5]    0.7262878590  0.875745952 0.0087574595 0.00740596596 10000.0000
# a_pond[36]    0.8278459525  0.433666591 0.0043366659 0.00340041538 10000.0000
# a_pond[22]   -0.9954707978  0.698527821 0.0069852782 0.00639152189 10000.0000
#  a_pond[2]    1.5514073486  0.973915502 0.0097391550 0.01111824521  7673.0859
# a_pond[59]    3.9781779304  1.018961505 0.0101896150 0.01278245028  6354.5870
# a_pond[46]    2.0703897434  0.515233417 0.0051523342 0.00470261856 10000.0000
#          σ    1.6843877698  0.243610374 0.0024361037 0.00421903982  3333.9901
# a_pond[47]    3.9862598194  1.020488268 0.0102048827 0.01240672087  6765.5329
# a_pond[57]    2.0741920322  0.509608416 0.0050960842 0.00391260407 10000.0000
# a_pond[23]   -0.9989820391  0.681962640 0.0068196264 0.00642167767 10000.0000
# a_pond[51]    2.7344759539  0.649587763 0.0064958776 0.00648076189 10000.0000
# a_pond[20]    0.5764910930  0.625086947 0.0062508695 0.00506310281 10000.0000
#  a_pond[8]    2.7496005216  1.272989569 0.0127298957 0.01733946864  5389.8679
# a_pond[18]    3.1900259466  1.171811970 0.0117181197 0.01440863531  6614.0909
# a_pond[54]    3.2291234955  0.784255555 0.0078425556 0.00820057334  9145.9069
# a_pond[11]    2.7535202736  1.237297764 0.0123729776 0.01757842164  4954.3730
# a_pond[16]    2.2007440950  0.916943320 0.0091694332 0.00992638854  8533.0137
#         lp -214.2598610993  7.211089559 0.0721108956 0.13728259285  2759.1215
# a_pond[44]    1.4579671233  0.494609207 0.0049460921 0.00415623790 10000.0000
#  a_pond[7]    1.5544027763  0.979190641 0.0097919064 0.01106135909  7836.4168
#     lf_eps    0.0806304543  0.025824042 0.0002582404 0.00087843406   864.2315
# a_pond[50]    1.2646118079  0.396937728 0.0039693773 0.00301671654 10000.0000
# a_pond[1]    2.7358650934  1.256841000 0.0125684100 0.01628364652  5957.4080
#   epsilon    0.0806304543  0.025824042 0.0002582404 0.00087843406   864.2315
# a_pond[55]    1.6194868499  0.449848512 0.0044984851 0.00337126412 10000.0000
# a_pond[56]    0.4636724052  0.333661394 0.0033366139 0.00317090692 10000.0000
# a_pond[9]   -1.5582336653  1.054033998 0.0105403400 0.01325783842  6320.6799
#  eval_num  140.7574000000 49.461823586 0.4946182359 1.04675890947  2232.7851
# a_pond[38]    2.4213667923  0.669981340 0.0066998134 0.00670341721  9989.2507
# a_pond[41]    2.9441756245  0.805063431 0.0080506343 0.00777409335 10000.0000
#    lf_num    0.0002000000  0.020000000 0.0002000000 0.00020000000 10000.0000
# a_pond[42]    1.0189318364  0.450896154 0.0045089615 0.00353871779 10000.0000
# a_pond[6]    0.7172274132  0.875913940 0.0087591394 0.00921226138  9040.4568
# a_pond[37]    1.2311086658  0.467581916 0.0046758192 0.00370489273 10000.0000
# a_pond[17]    2.1840208942  0.885232595 0.0088523259 0.01005752459  7746.9827
# a_pond[34]    3.7647116451  1.070577317 0.0107057732 0.01454992135  5413.9568
# a_pond[25]    0.1983088389  0.595635693 0.0059563569 0.00423421680 10000.0000
# a_pond[49]    3.2308198064  0.783408432 0.0078340843 0.00741996001 10000.0000
# a_pond[29]    0.5869977398  0.641031578 0.0064103158 0.00596687017 10000.0000
#   elapsed    0.2124224895  0.091334338 0.0009133434 0.00277238819  1085.3257
# a_pond[3]    2.7351595176  1.252877992 0.0125287799 0.01650408216  5762.8167
# a_pond[43]    1.4589068954  0.502713246 0.0050271325 0.00419773751 10000.0000
# a_pond[4]   -0.6955128978  0.886643420 0.0088664342 0.00892026440  9879.6722
# a_pond[28]    3.1799658392  1.190210605 0.0119021061 0.01598221933  5545.9182
# a_pond[15]    1.5668531946  1.015083021 0.0101508302 0.01066654407  9056.4014
# a_pond[24]    1.0178669471  0.671538554 0.0067153855 0.00534254055 10000.0000
# a_pond[32]    0.4829825423  0.408095990 0.0040809599 0.00290615908 10000.0000
# a_pond[30]    2.1782787743  0.892245915 0.0089224591 0.00878540719 10000.0000
# a_pond[60]    2.7321739924  0.664559051 0.0066455905 0.00632100816 10000.0000
# Rethinking
#             mean   sd  5.5% 94.5% n_eff Rhat
# a           1.30 0.23  0.94  1.67  8064    1
# sigma       1.55 0.21  1.24  1.92  3839    1
# a_pond[1]   2.57 1.17  0.85  4.57  9688    1
# a_pond[2]   2.58 1.19  0.83  4.56  9902    1
# a_pond[3]   2.56 1.16  0.84  4.57 12841    1
# a_pond[4]   1.49 0.92  0.12  3.03 15532    1
# a_pond[5]   1.51 0.95  0.07  3.09 14539    1
# a_pond[6]   0.72 0.84 -0.59  2.08 13607    1
# a_pond[7]   2.56 1.16  0.86  4.51 12204    1
# a_pond[8]   1.50 0.93  0.07  3.05 19903    1
# a_pond[9]   2.56 1.15  0.86  4.51 11054    1
# a_pond[10]  1.49 0.95  0.05  3.09 14134    1
# a_pond[11] -0.64 0.86 -2.06  0.70 15408    1
# a_pond[12]  2.56 1.16  0.86  4.53 11512    1
# a_pond[13]  1.49 0.95  0.05  3.10 16270    1
# a_pond[14]  0.71 0.84 -0.59  2.07 17077    1
# a_pond[15]  1.50 0.93  0.10  3.05 16996    1
# a_pond[16]  2.98 1.07  1.45  4.84  9033    1
# a_pond[17]  2.09 0.84  0.85  3.54 14636    1
# a_pond[18]  1.01 0.66  0.00  2.10 12971    1
# a_pond[19]  1.01 0.68 -0.03  2.13 12598    1
# a_pond[20]  1.48 0.72  0.38  2.67 15500    1
# a_pond[21]  2.96 1.09  1.42  4.87 11204    1
# a_pond[22] -2.04 0.87 -3.53 -0.75  9065    1
# a_pond[23]  0.99 0.67 -0.04  2.11 15365    1
# a_pond[24]  1.48 0.72  0.41  2.67 14879    1
# a_pond[25]  2.10 0.85  0.85  3.53 13298    1
# a_pond[26]  1.00 0.65  0.01  2.06 18583    1
# a_pond[27]  3.00 1.08  1.44  4.86  9312    1
# a_pond[28]  0.98 0.66 -0.03  2.09 14703    1
# a_pond[29]  0.21 0.61 -0.76  1.19 15554    1
# a_pond[30]  2.95 1.05  1.45  4.73  9816    1
# a_pond[31]  1.70 0.53  0.89  2.59 19148    1
# a_pond[32]  0.82 0.42  0.17  1.51 13556    1
# a_pond[33]  0.32 0.40 -0.33  0.96 19388    1
# a_pond[34] -0.15 0.40 -0.79  0.48 18684    1
# a_pond[35]  3.57 0.98  2.19  5.26  8769    1
# a_pond[36]  0.16 0.40 -0.46  0.80 17595    1
# a_pond[37]  2.00 0.58  1.13  2.99 14669    1
# a_pond[38] -1.41 0.49 -2.22 -0.65 12957    1
# a_pond[39]  1.21 0.46  0.49  1.97 14185    1
# a_pond[40] -1.18 0.46 -1.95 -0.48 16142    1
# a_pond[41]  2.86 0.78  1.73  4.18 10508    1
# a_pond[42]  0.00 0.39 -0.61  0.63 16138    1
# a_pond[43]  1.43 0.48  0.70  2.24 17100    1
# a_pond[44]  2.86 0.77  1.75  4.15 12002    1
# a_pond[45] -1.40 0.49 -2.21 -0.66 14292    1
# a_pond[46]  0.12 0.33 -0.40  0.66 20425    1
# a_pond[47] -0.56 0.36 -1.14  0.00 18981    1
# a_pond[48]  1.11 0.38  0.52  1.73 14176    1
# a_pond[49]  3.81 0.95  2.47  5.45  8841    1
# a_pond[50]  2.05 0.50  1.31  2.88 15898    1
# a_pond[51] -1.40 0.41 -2.08 -0.76 17188    1
# a_pond[52] -0.11 0.34 -0.65  0.43 17158    1
# a_pond[53]  1.61 0.44  0.94  2.36 15132    1
# a_pond[54]  2.05 0.50  1.30  2.89 15799    1
# a_pond[55]  3.14 0.75  2.08  4.40 12702    1
# a_pond[56]  3.13 0.74  2.07  4.41 11143    1
# a_pond[57]  1.26 0.40  0.65  1.92 14587    1
# a_pond[58]  1.11 0.38  0.51  1.74 21740    1
# a_pond[59]  2.33 0.56  1.50  3.25 13116    1
# a_pond[60]  1.27 0.40  0.66  1.91 15611    1

#                Mean          SD        Naive SE        MCSE         ESS
#          α   -1.43756402  0.167281208 0.0016728121 0.00210877863  6292.63192
#          σ    0.94572510  0.159509660 0.0015950966 0.00292977115  2964.19373
# a_pond[13]   -0.96409032  0.695682000 0.0069568200 0.00712009032  9546.63960
# a_pond[39]   -2.16432055  0.560230451 0.0056023045 0.00401929327 10000.00000
# a_pond[12]   -0.98211221  0.700132015 0.0070013202 0.00719599345  9466.25839
# a_pond[33]   -1.89716948  0.507094638 0.0050709464 0.00393759633 10000.00000
# a_pond[40]   -2.15927404  0.553498230 0.0055349823 0.00525989968 10000.00000
# a_pond[52]   -1.95778572  0.468392293 0.0046839229 0.00295136724 10000.00000
# a_pond[48]   -2.17567314  0.487971067 0.0048797107 0.00325138185 10000.00000
# a_pond[31]   -1.65553570  0.479752516 0.0047975252 0.00309756598 10000.00000
# a_pond[21]   -1.46693217  0.634848584 0.0063484858 0.00548329380 10000.00000
# a_pond[14]   -0.51655733  0.697560885 0.0069756089 0.00693184327 10000.00000
# a_pond[26]   -1.11415242  0.579221588 0.0057922159 0.00497058099 10000.00000
# a_pond[35]   -2.16959658  0.546408662 0.0054640866 0.00487151680 10000.00000
# a_pond[53]   -2.17290466  0.499898730 0.0049989873 0.00381882101 10000.00000
# a_pond[45]   -1.65831075  0.475684574 0.0047568457 0.00282288126 10000.00000
# a_pond[27]   -1.47390856  0.625904201 0.0062590420 0.00597555549 10000.00000
# a_pond[10]   -0.06470584  0.709512539 0.0070951254 0.00810899930  7655.71265
# a_pond[19]   -1.47611448  0.619367365 0.0061936736 0.00573498517 10000.00000
# a_pond[58]   -1.96067155  0.471148496 0.0047114850 0.00310756256 10000.00000
#  a_pond[5]   -0.51301911  0.693083568 0.0069308357 0.00766059211  8185.52478
# a_pond[36]   -2.16398901  0.552362190 0.0055236219 0.00423015168 10000.00000
# a_pond[22]   -0.79183001  0.562682452 0.0056268245 0.00395177756 10000.00000
#  a_pond[2]   -0.07065260  0.723388535 0.0072338853 0.00837009596  7469.34241
# a_pond[59]   -3.04846657  0.659338141 0.0065933814 0.00767658576  7377.00686
# a_pond[46]   -2.41950226  0.530010130 0.0053001013 0.00447275751 10000.00000
# a_pond[47]   -2.41940262  0.529600266 0.0052960027 0.00495650076 10000.00000
# a_pond[57]   -2.42196906  0.545199651 0.0054519965 0.00421172829 10000.00000
# a_pond[23]   -1.47836307  0.626164879 0.0062616488 0.00546703424 10000.00000
# a_pond[51]   -1.95865755  0.453931725 0.0045393173 0.00323782050 10000.00000
# a_pond[20]   -1.87882953  0.685389064 0.0068538906 0.00691600262  9821.18842
#  a_pond[8]   -0.51278872  0.698168747 0.0069816875 0.00674015806 10000.00000
# a_pond[18]   -0.79464713  0.570683666 0.0057068367 0.00517526089 10000.00000
# a_pond[54]   -2.17663143  0.486692179 0.0048669218 0.00357970522 10000.00000
# a_pond[11]   -0.52002272  0.700422488 0.0070042249 0.00758407273  8529.33523
# a_pond[16]   -2.35154693  0.748462872 0.0074846287 0.01009234165  5499.92332
# a_pond[44]   -2.16190756  0.555077841 0.0055507784 0.00464353670 10000.00000
#  a_pond[7]   -0.07294353  0.722895184 0.0072289518 0.00933609743  5995.42414
# a_pond[50]   -1.76719334  0.433238573 0.0043323857 0.00301606024 10000.00000
#  a_pond[1]   -0.07479566  0.715498813 0.0071549881 0.00821909124  7578.27275
# a_pond[55]   -1.95861084  0.462566383 0.0046256638 0.00326122131 10000.00000
# a_pond[56]   -1.95767294  0.451852167 0.0045185217 0.00336244216 10000.00000
#  a_pond[9]   -0.97174862  0.706466469 0.0070646647 0.00685957974 10000.00000
# a_pond[38]   -1.65719327  0.477253975 0.0047725397 0.00357994187 10000.00000
# a_pond[41]   -2.47295206  0.610429423 0.0061042942 0.00555558551 10000.00000
# a_pond[42]   -1.65879054  0.487850118 0.0048785012 0.00420032610 10000.00000
#  a_pond[6]   -0.51322197  0.699819483 0.0069981948 0.00837828549  6976.88795
# a_pond[37]   -1.89163219  0.514164120 0.0051416412 0.00396572368 10000.00000
# a_pond[17]   -0.48373615  0.562778997 0.0056277900 0.00445855972 10000.00000
# a_pond[34]   -1.89391017  0.517579732 0.0051757973 0.00449881473 10000.00000
# a_pond[25]   -0.48483903  0.564804766 0.0056480477 0.00432604358 10000.00000
# a_pond[49]   -1.95877851  0.456040949 0.0045604095 0.00251026103 10000.00000
# a_pond[29]   -1.47041681  0.615401982 0.0061540198 0.00516784541 10000.00000
#  a_pond[3]   -0.52147126  0.688164420 0.0068816442 0.00702386169  9599.14444
# a_pond[43]   -1.65667827  0.476433792 0.0047643379 0.00374622975 10000.00000
#  a_pond[4]   -0.97038449  0.704920197 0.0070492020 0.00798856637  7786.49863
# a_pond[28]   -1.11670032  0.594046332 0.0059404633 0.00481138686 10000.00000
# a_pond[15]   -0.97643818  0.702064283 0.0070206428 0.00627008271 10000.00000
# a_pond[24]   -0.78700355  0.580971213 0.0058097121 0.00463692344 10000.00000
# a_pond[32]   -1.66143918  0.481944799 0.0048194480 0.00375554807 10000.00000
# a_pond[30]   -0.79075103  0.573147275 0.0057314727 0.00550557273 10000.00000
# a_pond[60]   -2.17672820  0.503739378 0.0050373938 0.00376315154 10000.00000